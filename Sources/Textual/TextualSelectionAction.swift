#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  /// A normalized rectangle that identifies where text is rendered.
  ///
  /// `TextualTextAnchor` stores the center point and optional size of rendered text relative to
  /// the text view bounds. All values are clamped to the `0...1` range.
  public struct TextualTextAnchor: Equatable, Hashable, Sendable {
    /// The normalized horizontal center of the rendered text bounds.
    public let x: Double

    /// The normalized vertical center of the rendered text bounds.
    public let y: Double

    /// The normalized width of the rendered text bounds, when available.
    public let width: Double?

    /// The normalized height of the rendered text bounds, when available.
    public let height: Double?

    /// Creates a normalized text anchor.
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

  /// A concrete text fragment involved in a text interaction.
  public struct TextualTextFragment: Equatable, Sendable {
    /// The fragment text after whitespace and newline runs have been collapsed to single spaces.
    public let text: String

    /// The fragment range in the full text model, expressed as `NSAttributedString` character
    /// offsets.
    public let range: Range<Int>?

    /// The normalized anchor for the rendered fragment bounds within the text view.
    public let anchor: TextualTextAnchor?

    /// Creates a text fragment.
    public init(
      text: String,
      range: Range<Int>? = nil,
      anchor: TextualTextAnchor? = nil
    ) {
      self.text = text
      self.range = range
      self.anchor = anchor
    }
  }

  /// A rendered text block that contains an interaction target.
  public struct TextualTextBlock: Equatable, Sendable {
    /// The block text after whitespace and newline runs have been collapsed to single spaces.
    public let text: String

    /// The block range in the full text model, expressed as `NSAttributedString` character
    /// offsets.
    public let range: Range<Int>?

    /// The zero-based index of the containing layout block.
    public let index: Int?

    /// The normalized anchor for the rendered block bounds within the text view.
    public let anchor: TextualTextAnchor?

    /// Creates a text block.
    public init(
      text: String,
      range: Range<Int>? = nil,
      index: Int? = nil,
      anchor: TextualTextAnchor? = nil
    ) {
      self.text = text
      self.range = range
      self.index = index
      self.anchor = anchor
    }
  }

  /// Information passed to a custom selection action.
  ///
  /// `TextualSelectionPayload` describes the selected text and the rendered text block that
  /// contains it.
  public struct TextualSelectionPayload: Equatable, Sendable {
    /// The selected text fragment.
    public let selection: TextualTextFragment

    /// The rendered text block containing the selection.
    public let block: TextualTextBlock

    /// Creates a selection payload.
    public init(
      selection: TextualTextFragment,
      block: TextualTextBlock
    ) {
      self.selection = selection
      self.block = block
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
