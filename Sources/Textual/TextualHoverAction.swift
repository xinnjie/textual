#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  /// Information passed to a custom hover action.
  ///
  /// `TextualHoverPayload` describes the text block currently under the pointer and optional
  /// location metadata that callers can use to map the hover target back to rendered text.
  public struct TextualHoverPayload: Equatable, Sendable {
    /// The containing block text after whitespace and newline runs have been collapsed to single
    /// spaces.
    public let contextText: String

    /// The character range under the pointer in the full text model, expressed as
    /// `NSAttributedString` character offsets.
    public let hoverRange: Range<Int>?

    /// The containing block range in the full text model, expressed as `NSAttributedString`
    /// character offsets.
    public let contextRange: Range<Int>?

    /// The zero-based ordinal of the containing layout block.
    public let blockOrdinal: Int?

    /// The normalized anchor for the rendered hover bounds within the text view.
    public let attachmentAnchor: TextualSelectionAnchor?

    /// Creates a hover payload.
    ///
    /// - Parameters:
    ///   - contextText: The containing block text for the hover target.
    ///   - hoverRange: The hovered range in the full text model.
    ///   - contextRange: The containing block range in the full text model.
    ///   - blockOrdinal: The zero-based ordinal of the containing layout block.
    ///   - attachmentAnchor: The normalized rendered bounds for the hover target.
    public init(
      contextText: String,
      hoverRange: Range<Int>? = nil,
      contextRange: Range<Int>? = nil,
      blockOrdinal: Int? = nil,
      attachmentAnchor: TextualSelectionAnchor? = nil
    ) {
      self.contextText = contextText
      self.hoverRange = hoverRange
      self.contextRange = contextRange
      self.blockOrdinal = blockOrdinal
      self.attachmentAnchor = attachmentAnchor
    }
  }

  /// Handles hover updates for selectable textual content.
  ///
  /// The action receives the hover payload currently under the pointer.
  /// A `nil` payload indicates that the pointer has left selectable text or no
  /// hover payload is available.
  public typealias TextualHoverAction = @MainActor (TextualHoverPayload?) -> Void

  extension TextualNamespace where Base: View {
    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    /// Registers an action that is called when the pointer hovers over
    /// selectable textual content in this view hierarchy.
    ///
    /// Pass `nil` to clear an inherited hover action.
    public func textHoverAction(_ action: TextualHoverAction?) -> some View {
      base.environment(\.textHoverAction, action)
    }
  }

  extension EnvironmentValues {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    /// The hover callback used by textual selection views to report the
    /// selection payload currently under the pointer.
    ///
    /// A `nil` value means hover updates are not reported.
    @Entry var textHoverAction: TextualHoverAction?
  }
#endif
