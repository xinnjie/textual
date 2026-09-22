import SwiftUI

// MARK: - Overview
//
// Anchors are stored in attributed content as a `Textual.TextAnchor` attribute, but an
// `AttributedString` attribute does not survive the trip through `Text` into a resolved
// `Text.Layout`.
//
// `TextAnchorAttribute` is attached to the corresponding runs during `Text` construction, the same
// way links are, so `TextAnchorReporter` can recover which runs belong to which anchor once the
// layout resolves. This mirrors `LinkAttribute` and `AttachmentAttribute`.

struct TextAnchorAttribute: TextAttribute {
  var name: String

  init(_ name: String) {
    self.name = name
  }
}

extension Text.Layout.Run {
  var textAnchor: String? {
    self[TextAnchorAttribute.self]?.name
  }
}
