#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  /// A normalized rectangle that identifies where selected text is rendered.
  ///
  /// `TextualSelectionAnchor` stores the center point and optional size of a rendered selection
  /// relative to the text view bounds. All values are clamped to the `0...1` range.
  public struct TextualSelectionAnchor: Equatable, Hashable, Sendable {
    /// The normalized horizontal center of the rendered selection bounds.
    public let x: Double

    /// The normalized vertical center of the rendered selection bounds.
    public let y: Double

    /// The normalized width of the rendered selection bounds, when available.
    public let width: Double?

    /// The normalized height of the rendered selection bounds, when available.
    public let height: Double?

    /// Creates a normalized selection anchor.
    public init(x: Double, y: Double, width: Double? = nil, height: Double? = nil) {
      self.x = min(max(x, 0), 1)
      self.y = min(max(y, 0), 1)
      self.width = Self.normalizedDimension(width)
      self.height = Self.normalizedDimension(height)
    }

    private static func normalizedDimension(_ value: Double?) -> Double? {
      guard let value, value.isFinite else { return nil }
      return min(max(value, 0), 1)
    }
  }

  /// Information passed to a custom selection action.
  ///
  /// `TextualSelectionPayload` describes the selected text, the surrounding block used as
  /// context, and optional location metadata that callers can use to map the payload back to
  /// the rendered text.
  public struct TextualSelectionPayload: Equatable, Sendable {
    /// The selected text after whitespace and newline runs have been collapsed to single spaces.
    public let selectedText: String

    /// The containing block text after whitespace and newline runs have been collapsed to single
    /// spaces.
    public let contextText: String

    /// The selected range in the full text model, expressed as `NSAttributedString` character
    /// offsets.
    public let selectionRange: Range<Int>?

    /// The containing block range in the full text model, expressed as `NSAttributedString`
    /// offsets.
    public let contextRange: Range<Int>?

    /// The zero-based ordinal of the containing layout block.
    public let blockOrdinal: Int?

    /// The normalized anchor for the rendered selection bounds within the text view.
    public let attachmentAnchor: TextualSelectionAnchor?

    /// Creates a selection payload.
    public init(
      selectedText: String,
      contextText: String,
      selectionRange: Range<Int>? = nil,
      contextRange: Range<Int>? = nil,
      blockOrdinal: Int? = nil,
      attachmentAnchor: TextualSelectionAnchor? = nil
    ) {
      self.selectedText = selectedText
      self.contextText = contextText
      self.selectionRange = selectionRange
      self.contextRange = contextRange
      self.blockOrdinal = blockOrdinal
      self.attachmentAnchor = attachmentAnchor
    }
  }

  /// A custom action that can be presented for a textual selection.
  ///
  /// Textual selection actions are stored in the environment and invoked by the platform
  /// selection UI when the user chooses the corresponding command.
  public struct TextualSelectionAction: Identifiable {
    /// A stable identifier for this action.
    ///
    /// Use a unique value per action so callers can update or compare action lists reliably.
    public let id: String

    /// The default title shown for this action.
    ///
    /// When the action was created with a dynamic title resolver, this value is used as the
    /// fallback title.
    public let title: String

    private let titleResolver: @MainActor (TextualSelectionPayload) -> String?
    private let handler: @MainActor (TextualSelectionPayload) -> Void

    /// Creates a selection action with a fixed title.
    ///
    /// - Parameters:
    ///   - id: A stable identifier for the action.
    ///   - title: The title shown in the selection UI.
    ///   - handler: The closure called when the action is performed.
    public init(
      id: String,
      title: String,
      handler: @MainActor @escaping (TextualSelectionPayload) -> Void
    ) {
      self.id = id
      self.title = title
      self.titleResolver = { _ in title }
      self.handler = handler
    }

    /// Creates a selection action with a title that can vary by selection payload.
    ///
    /// Return `nil` from `title` to hide the action for a particular selection.
    ///
    /// - Parameters:
    ///   - id: A stable identifier for the action.
    ///   - fallbackTitle: The title used when a concrete payload is not available.
    ///   - title: A resolver that returns the title for the current selection, or `nil` to hide
    ///     the action.
    ///   - handler: The closure called when the action is performed.
    public init(
      id: String,
      fallbackTitle: String,
      title: @MainActor @escaping (TextualSelectionPayload) -> String?,
      handler: @MainActor @escaping (TextualSelectionPayload) -> Void
    ) {
      self.id = id
      self.title = fallbackTitle
      self.titleResolver = title
      self.handler = handler
    }

    /// Returns the title to display for a selection payload.
    ///
    /// A `nil` result means the action should not be shown for that payload.
    @MainActor
    public func title(for payload: TextualSelectionPayload) -> String? {
      titleResolver(payload)
    }

    /// Performs the action for the supplied selection payload.
    @MainActor
    public func perform(with payload: TextualSelectionPayload) {
      handler(payload)
    }
  }

  extension TextualNamespace where Base: View {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    /// Registers custom actions for textual selections in this view hierarchy.
    ///
    /// The actions are made available to Textual's selection interaction where supported by the
    /// platform.
    public func textSelectionActions(_ actions: [TextualSelectionAction]) -> some View {
      base.environment(\.textSelectionActions, actions)
    }
  }

  extension EnvironmentValues {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    /// The custom actions available for textual selections.
    @Entry var textSelectionActions: [TextualSelectionAction] = []
  }
#endif
