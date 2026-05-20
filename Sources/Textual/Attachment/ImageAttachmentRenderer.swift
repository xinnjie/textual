import SwiftUI

/// Resolves Markdown image URLs into renderable Textual attachments.
///
/// Textual asks the renderer for a concrete attachment before building `Text.Layout` so the
/// attachment can report a stable size for placeholder layout.
public protocol ImageAttachmentRenderer: Sendable {
  /// Loads an image attachment for the given request.
  func attachment(for request: ImageAttachmentRequest) async throws -> AnyAttachment
}

/// The information needed to resolve a Markdown image attachment.
public struct ImageAttachmentRequest: Hashable, Sendable {
  public let url: URL
  public let text: String
  public let environment: ColorEnvironmentValues

  public init(
    url: URL,
    text: String,
    environment: ColorEnvironmentValues
  ) {
    self.url = url
    self.text = text
    self.environment = environment
  }
}

/// The default image renderer backed by Textual's built-in image loader.
public struct TextualImageAttachmentRenderer: ImageAttachmentRenderer {
  public init() {}

  public func attachment(for request: ImageAttachmentRequest) async throws -> AnyAttachment {
    let image = try await ImageLoader.shared.image(for: request.url)
    let attachment: any Attachment = ImageAttachment(image: image, text: request.text)
    return AnyAttachment(attachment)
  }
}

extension ImageAttachmentRenderer where Self == TextualImageAttachmentRenderer {
  /// Textual's built-in image renderer.
  public static var textual: Self {
    .init()
  }
}
