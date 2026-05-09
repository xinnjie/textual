#if TEXTUAL_ENABLE_TEXT_SELECTION
  import Foundation

  extension TextSelectionModel {
    func textualSelectionPayload(
      for selectedRange: TextRange,
      in bounds: CGRect
    ) -> TextualSelectionPayload? {
      let selectedText = normalizedSelectionText(text(in: selectedRange))
      guard selectedText.isEmpty == false else { return nil }

      let contextRange = blockRange(for: selectedRange.start)
      let contextText = normalizedSelectionText(
        contextRange.map { text(in: $0) } ?? text(in: selectedRange)
      )
      let rects = selectionRects(for: selectedRange).map(\.rect)

      return TextualSelectionPayload(
        selectedText: selectedText,
        contextText: contextText.isEmpty ? selectedText : contextText,
        selectionRange: globalRange(for: selectedRange),
        contextRange: contextRange.flatMap { globalRange(for: $0) },
        blockOrdinal: contextRange?.start.indexPath.layout,
        attachmentAnchor: textualSelectionAnchor(for: rects, in: bounds)
      )
    }

    private func globalRange(for range: TextRange) -> Range<Int>? {
      let start = offset(from: startPosition, to: range.start)
      let end = offset(from: startPosition, to: range.end)
      guard start <= end else { return nil }
      return start..<end
    }
  }

  private func normalizedSelectionText(_ text: String) -> String {
    text
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { $0.isEmpty == false }
      .joined(separator: " ")
  }

  private func textualSelectionAnchor(
    for rects: [CGRect],
    in bounds: CGRect
  ) -> TextualSelectionAnchor? {
    guard bounds.width > 0, bounds.height > 0 else { return nil }

    let selectionRect = rects.reduce(CGRect.null) { partialResult, rect in
      partialResult.union(rect)
    }

    guard selectionRect.isNull == false else { return nil }

    return TextualSelectionAnchor(
      x: Double(selectionRect.midX / bounds.width),
      y: Double(selectionRect.midY / bounds.height),
      width: Double(selectionRect.width / bounds.width),
      height: Double(selectionRect.height / bounds.height)
    )
  }
#endif
