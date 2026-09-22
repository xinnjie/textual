import SwiftUI

// MARK: - Overview
//
// `TextAnchorReporter` reports where anchored spans were rendered.
//
// It is applied at the text fragment level, alongside `AttachmentOverlay`, and reads the same
// resolved geometry: the `Text.LayoutKey` preference gives the anchored layouts, and each run in a
// layout knows whether it carries a `TextAnchorAttribute`. A run's `typographicBounds` is the
// rectangle the anchored words occupy.
//
// Rectangles are reported in the `.textContainer` coordinate space, which `InlineText` and
// `StructuredText` establish, so a caller receives one set of coordinates for the whole text no
// matter how many fragments it was rendered as. A span that wraps produces one rectangle per line,
// which is why the reported value is an array.

struct TextAnchorsPreferenceKey: PreferenceKey {
  static var defaultValue: [String: [CGRect]] { [:] }

  static func reduce(value: inout [String: [CGRect]], nextValue: () -> [String: [CGRect]]) {
    value.merge(nextValue()) { $0 + $1 }
  }
}

struct TextAnchorReporter: ViewModifier {
  func body(content: Content) -> some View {
    content
      .overlayPreferenceValue(Text.LayoutKey.self) { value in
        GeometryReader { geometry in
          Color.clear
            .preference(
              key: TextAnchorsPreferenceKey.self,
              value: anchors(in: value, geometry: geometry)
            )
        }
        .allowsHitTesting(false)
      }
  }

  private func anchors(
    in value: Text.LayoutKey.Value,
    geometry: GeometryProxy
  ) -> [String: [CGRect]] {
    let container = geometry.frame(in: .textContainer).origin
    var result: [String: [CGRect]] = [:]
    for anchoredLayout in value where anchoredLayout.layout.isTextFragment {
      let origin = geometry[anchoredLayout.origin]
      for line in anchoredLayout.layout {
        for run in line {
          guard let anchor = run.textAnchor else { continue }
          let rect = run.typographicBounds.rect.offsetBy(
            dx: origin.x + container.x,
            dy: origin.y + container.y
          )
          // The same fragment can be laid out more than once — SwiftUI measures before it
          // renders — and each pass reports the same run. Only genuinely distinct rectangles,
          // such as the two halves of a span that wrapped, are worth reporting.
          if result[anchor, default: []].contains(rect) { continue }
          result[anchor, default: []].append(rect)
        }
      }
    }
    return result
  }
}
