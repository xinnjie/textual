import SwiftUI

extension StructuredText {
  struct Heading: View {
    @Environment(\.headingStyle) private var headingStyle

    private let content: AttributedString
    private let level: Int

    init(_ content: AttributedString, level: Int) {
      self.content = content
      self.level = level
    }

    var body: some View {
      let configuration = HeadingStyleConfiguration(
        label: .init(label),
        indentationLevel: indentationLevel,
        headingLevel: level
      )
      let resolvedStyle = headingStyle.resolve(configuration: configuration)

      AnyView(resolvedStyle)
        .id(content.slugified())
    }

    private var label: some View {
      WithInlineStyle(content) {
        TextFragment($0)
      }
    }

    private var indentationLevel: Int {
      content.runs.first?.presentationIntent?.indentationLevel ?? 0
    }
  }
}
