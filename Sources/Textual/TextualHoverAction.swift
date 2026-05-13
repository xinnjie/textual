#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  /// Information passed to a custom hover action.
  ///
  /// `TextualHoverPayload` describes the text fragment currently under the pointer and the
  /// rendered text block that contains it.
  public struct TextualHoverPayload: Equatable, Sendable {
    /// The text fragment under the pointer.
    public let target: TextualTextFragment

    /// The rendered text block containing the hover target.
    public let block: TextualTextBlock

    /// Creates a hover payload.
    public init(
      target: TextualTextFragment,
      block: TextualTextBlock
    ) {
      self.target = target
      self.block = block
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
