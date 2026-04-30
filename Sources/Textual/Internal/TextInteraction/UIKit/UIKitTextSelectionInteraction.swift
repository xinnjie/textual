#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import SwiftUI

  // MARK: - Overview
  //
  // `UIKitTextSelectionInteraction` presents the platform-specific text selection overlay for iOS.
  //
  // The modifier receives a `TextSelectionModel` from `TextSelectionInteraction` and overlays
  // `UIKitTextInteractionOverlay`, which wraps a `UIView` that handles selection gestures and
  // integrates with system edit actions (copy/share). SwiftUI continues to render the text while
  // UIKit manages the selection interaction.

  typealias PlatformTextSelectionInteraction = UIKitTextSelectionInteraction

  struct UIKitTextSelectionInteraction: ViewModifier {
    private let model: TextSelectionModel
    private let selectionActions: [TextualSelectionAction]

    init(model: TextSelectionModel, selectionActions: [TextualSelectionAction]) {
      self.model = model
      self.selectionActions = selectionActions
    }

    func body(content: Content) -> some View {
      content.overlayPreferenceValue(OverflowFrameKey.self) { frames in
        UIKitTextInteractionOverlay(
          model: model,
          overflowFrames: frames,
          selectionActions: selectionActions
        )
      }
    }
  }
#endif
