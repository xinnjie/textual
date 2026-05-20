import SwiftUI

/// Configuration that controls Textual rendering behavior.
///
/// Pass a configuration to ``InlineText`` or ``StructuredText`` initializers to choose how
/// Markdown images and custom emoji are resolved. The default configuration preserves Textual's
/// built-in image and emoji behavior.
public struct TextualConfiguration: Sendable {
  /// The renderer used for Markdown image attachments.
  public var imageRenderer: any ImageAttachmentRenderer

  /// The loader used for custom emoji attachments.
  public var emojiAttachmentLoader: any AttachmentLoader

  public init(
    imageRenderer: any ImageAttachmentRenderer = TextualImageAttachmentRenderer(),
    emojiAttachmentLoader: any AttachmentLoader = URLAttachmentLoader<EmojiAttachment>.emoji()
  ) {
    self.imageRenderer = imageRenderer
    self.emojiAttachmentLoader = emojiAttachmentLoader
  }

  /// Textual's default rendering configuration.
  public static var `default`: Self {
    .init()
  }
}

extension EnvironmentValues {
  @Entry var textualConfiguration: TextualConfiguration = .default
}
