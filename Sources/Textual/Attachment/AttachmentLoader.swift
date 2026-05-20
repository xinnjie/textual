import SwiftUI

/// Loads attachments referenced by markup.
///
/// Textual uses attachment loaders to turn URLs (for example image links or custom emoji URLs)
/// into concrete ``Attachment`` values.
///
/// Custom emoji still use attachment loaders directly. Markdown images are configured with the
/// image renderer in ``TextualConfiguration``; ``TextualNamespace/imageAttachmentLoader(_:)``
/// remains available as a compatibility override.
///
/// For existing code that uses image loader modifiers, relative image URLs can still be resolved
/// by providing a base URL to ``TextualNamespace/imageAttachmentLoader(_:)``:
///
/// ```swift
/// StructuredText(
///   markdown: """
///     These images are using an `URLAttachmentLoader` instance
///     relative to `https://picsum.photos/seed/textual`:
///
///     ![](400/250)
///     ![](300/125)
///     """
/// )
/// .textual.imageAttachmentLoader(
///   .image(relativeTo: URL(string: "https://picsum.photos/seed/textual")!)
/// )
/// ```
///
/// If your markup uses asset names, map the URL to an asset catalog entry:
///
/// ```swift
/// let emoji: Set<Emoji> = [
///   Emoji(shortcode: "sad_dog", url: URL(string: "sad_dog")!)
/// ]
///
/// StructuredText(
///   markdown: "![Alt text](sad_dog) :sad_dog:",
///   syntaxExtensions: [.emoji(emoji)]
/// )
/// .textual.imageAttachmentLoader(.image(named: \.lastPathComponent))
/// .textual.emojiAttachmentLoader(.emoji(named: \.lastPathComponent))
/// ```
public protocol AttachmentLoader: Sendable {
  associatedtype Attachment: Textual.Attachment

  /// Loads an attachment for the given URL.
  ///
  /// - Parameters:
  ///   - url: The URL found in the markup.
  ///   - text: The original text associated with the URL (for example, image alt text).
  ///   - environment: The current color environment, useful for appearance-aware attachments.
  func attachment(
    for url: URL,
    text: String,
    environment: ColorEnvironmentValues
  ) async throws -> Attachment
}

extension EnvironmentValues {
  @Entry var imageAttachmentLoader: (any AttachmentLoader)?
  @Entry var emojiAttachmentLoader: (any AttachmentLoader)?
}
