import SwiftUI

// MARK: - Overview
//
// `WithAttachments` resolves attachment references in an `AttributedString`.
//
// Markup parsing keeps some items as URL attributes:
// - `run.imageURL` for images
// - `run.textual.emojiURL` for custom emoji references emitted by pattern expansion
//
// This view asynchronously resolves those URLs using the configured image renderer and emoji
// loader, then writes the resolved attachments back into the attributed string as
// `Textual.Attachment` attributes. The rest of the rendering pipeline treats attachment runs like
// any other span.

struct WithAttachments<Content: View>: View {
  @Environment(\.imageAttachmentLoader) private var imageAttachmentLoader
  @Environment(\.emojiAttachmentLoader) private var emojiAttachmentLoader
  @Environment(\.colorEnvironment) private var colorEnvironment

  @State private var model = Model()

  private let attributedString: AttributedString
  private let configuration: TextualConfiguration
  private let content: (AttributedString) -> Content

  init(
    _ attributedString: AttributedString,
    configuration: TextualConfiguration,
    @ViewBuilder content: @escaping (AttributedString) -> Content
  ) {
    self.attributedString = attributedString
    self.configuration = configuration
    self.content = content
  }

  var body: some View {
    content(model.resolvedAttributedString ?? attributedString)
      .task(id: attributedString) {
        await model.resolveAttachments(
          in: attributedString,
          configuration: configuration,
          imageAttachmentLoaderOverride: imageAttachmentLoader,
          emojiAttachmentLoaderOverride: emojiAttachmentLoader,
          environment: colorEnvironment
        )
      }
  }
}

extension WithAttachments {
  @MainActor @Observable final class Model {
    var resolvedAttributedString: AttributedString?

    func resolveAttachments(
      in attributedString: AttributedString,
      configuration: TextualConfiguration,
      imageAttachmentLoaderOverride: (any AttachmentLoader)?,
      emojiAttachmentLoaderOverride: (any AttachmentLoader)?,
      environment: ColorEnvironmentValues
    ) async {
      guard attributedString.containsValues(for: [\.imageURL, \.textual.emojiURL]) else {
        resolvedAttributedString = nil
        return
      }

      var attachments: [AnyAttachment] = []
      var ranges: [Range<AttributedString.Index>] = []

      await withTaskGroup(
        of: (AnyAttachment?, Range<AttributedString.Index>).self
      ) { group in
        for run in attributedString.runs {
          if let imageURL = run.imageURL {
            group.addTask {
              let text = String(attributedString[run.range].characters[...])
              let attachment =
                if let imageAttachmentLoaderOverride {
                  try? await imageAttachmentLoaderOverride.attachment(
                    for: imageURL,
                    text: text,
                    environment: environment
                  ).erased()
                } else {
                  try? await configuration.imageRenderer.attachment(
                    for: .init(
                      url: imageURL,
                      text: text,
                      environment: environment
                    )
                  )
                }
              return (attachment, run.range)
            }
          } else if let emojiURL = run.textual.emojiURL {
            group.addTask {
              let attachment = try? await (
                emojiAttachmentLoaderOverride ?? configuration.emojiAttachmentLoader
              ).attachment(
                for: emojiURL,
                text: String(attributedString[run.range].characters[...]),
                environment: environment
              )
              return (attachment.map(AnyAttachment.init), run.range)
            }
          }
        }

        for await (attachment, range) in group {
          guard let attachment else { continue }

          attachments.append(attachment)
          ranges.append(range)
        }
      }

      resolveAttachmentsFinished(
        attributedString: attributedString,
        attachments: Array(zip(ranges, attachments))
      )
    }

    private func resolveAttachmentsFinished(
      attributedString: AttributedString,
      attachments: [(Range<AttributedString.Index>, AnyAttachment)]
    ) {
      var attributedString = attributedString

      for (range, attachment) in attachments {
        attributedString[range].textual.attachment = attachment
      }

      self.resolvedAttributedString = attributedString
    }
  }
}

extension Attachment {
  fileprivate func erased() -> AnyAttachment {
    AnyAttachment(self as any Attachment)
  }
}
