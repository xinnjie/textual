import SwiftUI

extension AttributeScopes {
  /// Attributes used by Textual when parsing and rendering markup.
  public struct TextualAttributes: AttributeScope {
    /// Stores an attachment value in attributed content.
    public enum AttachmentAttribute: AttributedStringKey {
      public typealias Value = AnyAttachment
      public static let name = "Textual.Attachment"
    }

    /// Stores a URL for a custom emoji placeholder.
    ///
    /// Textual uses this attribute as an intermediate representation before resolving emoji into
    /// an attachment.
    public enum EmojiURLAttribute: AttributedStringKey {
      public typealias Value = URL
      public static let name = "Textual.EmojiURL"
    }

    /// Names a span so its rendered position can be observed.
    ///
    /// Textual lays text out; it does not tell you where a particular phrase ended up. Mark the
    /// spans you need to locate with this attribute, then read their rectangles with
    /// ``TextualNamespace/onTextAnchorsChange(_:)``. Use it to place your own views — a badge, a
    /// callout, the end of a connector — against words inside the rendered text.
    ///
    /// ```swift
    /// var content = try AttributedString(markdown: "A question is a short detour.")
    /// if let range = content.range(of: "a short detour") {
    ///   content[range].textual.textAnchor = "detour"
    /// }
    /// ```
    ///
    /// Anchors are opaque names chosen by the caller. Reusing one name for several spans is
    /// allowed and reports every one of them.
    public enum TextAnchorAttribute: AttributedStringKey {
      public typealias Value = String
      public static let name = "Textual.TextAnchor"
    }

    /// A property for accessing an attachment attribute.
    public let attachment: AttachmentAttribute

    /// A property for accessing an emoji URL attribute.
    public let emojiURL: EmojiURLAttribute

    /// A property for accessing a text anchor attribute.
    public let textAnchor: TextAnchorAttribute

    public let foundation: AttributeScopes.FoundationAttributes
  }

  /// The Textual attribute scope.
  public var textual: TextualAttributes.Type {
    TextualAttributes.self
  }
}

extension AttributeDynamicLookup {
  /// Provides dynamic member lookup for Textual attributes.
  public subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.TextualAttributes, T>
  ) -> T {
    return self[T.self]
  }
}
