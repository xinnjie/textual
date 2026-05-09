#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  public struct TextualSelectionAnchor: Equatable, Hashable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double?
    public let height: Double?

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

  public struct TextualSelectionPayload: Equatable, Sendable {
    public let selectedText: String
    public let contextText: String
    public let selectionRange: Range<Int>?
    public let contextRange: Range<Int>?
    public let blockOrdinal: Int?
    public let attachmentAnchor: TextualSelectionAnchor?

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

  public struct TextualSelectionAction: Identifiable {
    public let id: String
    public let title: String

    private let titleResolver: @MainActor (TextualSelectionPayload) -> String?
    private let handler: @MainActor (TextualSelectionPayload) -> Void

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

    @MainActor
    public func title(for payload: TextualSelectionPayload) -> String? {
      titleResolver(payload)
    }

    @MainActor
    public func perform(with payload: TextualSelectionPayload) {
      handler(payload)
    }
  }

  extension TextualNamespace where Base: View {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func textSelectionActions(_ actions: [TextualSelectionAction]) -> some View {
      base.environment(\.textSelectionActions, actions)
    }
  }

  extension EnvironmentValues {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @Entry var textSelectionActions: [TextualSelectionAction] = []
  }
#endif
