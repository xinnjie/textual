import SwiftUI

extension StructuredText {
  struct BlockContent<Content: AttributedStringProtocol>: View {
    private let parent: PresentationIntent.IntentType?
    private let content: Content

    init(parent: PresentationIntent.IntentType? = nil, content: Content) {
      self.parent = parent
      self.content = content
    }

    var body: some View {
      let runs = content.blockRuns(parent: parent)

      BlockVStack {
        ForEach(runs.indices, id: \.self) { index in
          let run = runs[index]
          Block(intent: run.intent, content: AttributedString(content[run.range]))
        }
      }
    }
  }
}

extension StructuredText {
  struct Block: View {
    @Environment(\.textualConfiguration) private var configuration

    private let intent: PresentationIntent.IntentType?
    private let content: AttributedString

    init(intent: PresentationIntent.IntentType?, content: AttributedString) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      switch intent?.kind {
      case .orderedList:
        OrderedList(intent: intent, content: content)
      case .unorderedList:
        UnorderedList(intent: intent, content: content)
      case .blockQuote:
        BlockQuote(intent: intent, content: content)
      case .table(let columns):
        Table(intent: intent, content: content, columns: columns)
      default:
        WithAttachments(content, configuration: configuration) { content in
          switch intent?.kind {
          case .paragraph where content.isMathBlock:
            MathBlock(content)
          case .paragraph:
            Paragraph(content)
          case .header(let level):
            Heading(content, level: level)
          case .codeBlock(let languageHint) where languageHint?.lowercased() == "math":
            MathCodeBlock(content)
          case .codeBlock(let languageHint):
            CodeBlock(content, languageHint: languageHint)
          case .thematicBreak:
            ThematicBreak(content)
          default:
            Paragraph(content)
          }
        }
      }
    }
  }
}
