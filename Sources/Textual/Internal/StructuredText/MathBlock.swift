import SwiftUI

extension StructuredText {
  struct MathBlock: View {
    @Environment(\.paragraphStyle) private var paragraphStyle
    @Environment(\.mathProperties) private var mathProperties

    private let content: AttributedString

    init(_ content: AttributedString) {
      self.content = content
    }

    var body: some View {
      let configuration = BlockStyleConfiguration(
        label: .init(label),
        indentationLevel: indentationLevel
      )
      let resolvedStyle = paragraphStyle.resolve(configuration: configuration)

      AnyView(resolvedStyle)
        .layoutValue(key: BlockAlignmentKey.self, value: mathProperties.textAlignment)
        .preference(key: BlockAlignmentKey.self, value: mathProperties.textAlignment)
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
