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
      let selectionRects = selectionRects(for: selectedRange).map(\.rect)

      return TextualSelectionPayload(
        selection: TextualTextFragment(
          text: selectedText,
          range: globalRange(for: selectedRange),
          anchor: textualTextAnchor(for: selectionRects, in: bounds)
        ),
        block: textualTextBlock(
          for: contextRange,
          fallbackText: contextText.isEmpty ? selectedText : contextText,
          in: bounds
        )
      )
    }

    func textualHoverPayload(
      at point: CGPoint,
      in bounds: CGRect
    ) -> TextualHoverPayload? {
      guard
        let characterRange = characterRange(containing: point),
        let contextRange = blockRange(for: characterRange.start)
      else {
        return nil
      }

      let contextText = normalizedSelectionText(text(in: contextRange))
      guard contextText.isEmpty == false else {
        return nil
      }

      return TextualHoverPayload(
        target: TextualTextFragment(
          text: normalizedSelectionText(text(in: characterRange)),
          range: globalRange(for: characterRange),
          anchor: textualTextAnchor(
            for: selectionRects(for: characterRange).map(\.rect),
            in: bounds
          )
        ),
        block: textualTextBlock(for: contextRange, fallbackText: contextText, in: bounds)
      )
    }

    private func globalRange(for range: TextRange) -> Range<Int>? {
      let start = offset(from: startPosition, to: range.start)
      let end = offset(from: startPosition, to: range.end)
      guard start <= end else { return nil }
      return start..<end
    }

    private func textualTextBlock(
      for range: TextRange?,
      fallbackText: String,
      in bounds: CGRect
    ) -> TextualTextBlock {
      guard let range else {
        return TextualTextBlock(text: fallbackText)
      }

      let text = normalizedSelectionText(text(in: range))
      return TextualTextBlock(
        text: text.isEmpty ? fallbackText : text,
        range: globalRange(for: range),
        index: range.start.indexPath.layout,
        anchor: textualTextAnchor(for: selectionRects(for: range).map(\.rect), in: bounds)
      )
    }
  }

  private func normalizedSelectionText(_ text: String) -> String {
    text
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { $0.isEmpty == false }
      .joined(separator: " ")
  }

  private func textualTextAnchor(
    for rects: [CGRect],
    in bounds: CGRect
  ) -> TextualTextAnchor? {
    guard bounds.width > 0, bounds.height > 0 else { return nil }

    let selectionRect = rects.reduce(CGRect.null) { partialResult, rect in
      partialResult.union(rect)
    }

    guard selectionRect.isNull == false else { return nil }

    return TextualTextAnchor(
      x: Double(selectionRect.midX / bounds.width),
      y: Double(selectionRect.midY / bounds.height),
      width: Double(selectionRect.width / bounds.width),
      height: Double(selectionRect.height / bounds.height)
    )
  }
#endif
