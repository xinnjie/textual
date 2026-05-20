import SwiftUI
import UniformTypeIdentifiers

extension StructuredText {
  /// A proxy for a rendered code block that custom code block styles can use.
  public struct CodeBlockProxy {
    private let content: AttributedString

    internal init(_ content: AttributedString) {
      self.content = content
    }

    /// Copies the code block contents to the system pasteboard.
    ///
    /// Textual writes both a plain-text and an HTML representation when possible.
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func copyToPasteboard() {
      #if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let formatter = Formatter(content)
        pasteboard.setString(formatter.plainText(), forType: .string)
        pasteboard.setString(formatter.html(), forType: .html)
      #elseif TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
        let formatter = Formatter(content)
        UIPasteboard.general.setItems(
          [
            [
              UTType.plainText.identifier: formatter.plainText(),
              UTType.html.identifier: formatter.html(),
            ]
          ]
        )
      #endif
    }
  }
}
