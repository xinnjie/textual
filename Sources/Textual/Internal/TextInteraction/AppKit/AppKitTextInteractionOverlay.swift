#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit)
  import SwiftUI

  // MARK: - Overview
  //
  // `AppKitTextInteractionOverlay` bridges the shared `TextSelectionModel` into an `NSView`.
  //
  // The overlay reads exclusion rectangles for hit-testing. This allows embedded scrollable regions (like
  // code blocks) to receive touch events while the parent handles text selection. The view also
  // manages selection gestures, keyboard-driven updates, and context menus while SwiftUI renders
  // the text.

  struct AppKitTextInteractionOverlay: NSViewRepresentable {
    private let model: TextSelectionModel
    private let overflowFrames: [CGRect]
    private let selectionActions: [TextualSelectionAction]
    private let hoverAction: TextualHoverAction?

    init(
      model: TextSelectionModel,
      overflowFrames: [CGRect],
      selectionActions: [TextualSelectionAction],
      hoverAction: TextualHoverAction?
    ) {
      self.model = model
      self.overflowFrames = overflowFrames
      self.selectionActions = selectionActions
      self.hoverAction = hoverAction
    }

    func makeNSView(context: Context) -> NSTextInteractionView {
      NSTextInteractionView(
        model: model,
        exclusionRects: overflowFrames,
        openURL: context.environment.openURL,
        selectionActions: selectionActions,
        hoverAction: hoverAction
      )
    }

    func updateNSView(_ nsView: NSTextInteractionView, context: Context) {
      nsView.model = model
      nsView.exclusionRects = overflowFrames
      nsView.openURL = context.environment.openURL
      nsView.selectionActions = selectionActions
      nsView.hoverAction = hoverAction
    }
  }
#endif
