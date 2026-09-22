#if os(macOS)
  import SwiftUI
  import Testing

  @testable import Textual

  @MainActor
  struct TextAnchorTests {
    private static let article = """
      A question should be a short detour from the paragraph, not a replacement for everything \
      the reader has yet to finish.

      Preserve the unfinished thought.
      """

    @Test func reportsTheRectangleOfAnAnchoredSpan() throws {
      let anchors = render(Self.article, anchoring: ["detour": "a short detour"], width: 320)

      let rects = try #require(anchors["detour"])
      #expect(rects.count == 1)
      #expect(rects[0].width > 0 && rects[0].height > 0)
      #expect(rects[0].minX >= 0 && rects[0].maxX <= 320)
    }

    @Test func reportsNothingForTextWithoutAnchors() {
      #expect(render(Self.article, anchoring: [:], width: 320).isEmpty)
    }

    @Test func reportsNothingForAPhraseThatIsNoLongerThere() {
      #expect(
        render(Self.article, anchoring: ["gone": "a paragraph since rewritten"], width: 320)
          .isEmpty)
    }

    @Test func reportsAnchorsInReadingOrder() throws {
      let anchors = render(
        Self.article,
        anchoring: ["first": "A question", "second": "unfinished thought"],
        width: 320
      )

      let first = try #require(anchors["first"]?.first)
      let second = try #require(anchors["second"]?.first)
      #expect(first.minY < second.minY)
    }

    @Test func reportsOneRectanglePerLineForAWrappedSpan() throws {
      // Narrow enough that the anchored phrase cannot sit on a single line.
      let anchors = render(
        Self.article,
        anchoring: ["wrapped": "a short detour from the paragraph"],
        width: 90
      )

      let rects = try #require(anchors["wrapped"])
      #expect(rects.count > 1)
      #expect(Set(rects.map(\.minY)).count == rects.count)
    }

    @Test func rectanglesFollowTheLayoutWhenTheWidthChanges() throws {
      let anchoring = ["detour": "a short detour"]
      let wide = try #require(render(Self.article, anchoring: anchoring, width: 320)["detour"])
      let narrow = try #require(render(Self.article, anchoring: anchoring, width: 140)["detour"])

      // The phrase fits on one line at 320pt and has to break at 140pt.
      #expect(wide.count == 1)
      #expect(narrow.count > wide.count)
      #expect(narrow[0].width < wide[0].width)
    }

    @Test func reportsAnchorsAcrossSeparateBlocks() throws {
      let anchors = render(
        Self.article,
        anchoring: ["opening": "A question", "closing": "Preserve"],
        width: 320
      )

      let opening = try #require(anchors["opening"]?.first)
      let closing = try #require(anchors["closing"]?.first)
      // The two phrases live in different paragraphs, so they are rendered by different fragments;
      // both still arrive in the coordinate space of the StructuredText that rendered them.
      #expect(opening.minY < closing.minY)
      #expect(opening.minX == closing.minX)
    }

    // MARK: - Helpers

    /// Lays `markdown` out at `width` in a real window and returns the reported anchors.
    ///
    /// A hosting view rather than `ImageRenderer`: `Text.Layout` lines only materialize once the
    /// text is laid out for display, so an off-screen render reports layouts with no runs in them.
    private func render(
      _ markdown: String,
      anchoring anchors: [String: String],
      width: CGFloat
    ) -> [String: [CGRect]] {
      let recorder = AnchorRecorder()
      let view =
        StructuredText(markdown, parser: AnchoringParser(anchors: anchors))
        .textual.onTextAnchorsChange { anchors in
          MainActor.assumeIsolated { recorder.anchors = anchors }
        }
        .frame(width: width)

      let hosting = NSHostingView(rootView: view)
      hosting.frame = CGRect(x: 0, y: 0, width: width, height: 2_000)
      let window = NSWindow(
        contentRect: hosting.frame,
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
      )
      window.contentView = hosting
      window.makeKeyAndOrderFront(nil)
      hosting.layoutSubtreeIfNeeded()
      hosting.displayIfNeeded()
      RunLoop.current.run(until: Date().addingTimeInterval(0.2))
      window.orderOut(nil)

      return recorder.anchors
    }
  }

  @MainActor
  private final class AnchorRecorder {
    var anchors: [String: [CGRect]] = [:]
  }

  /// Parses Markdown, then anchors the given phrases — the way a caller annotates rendered text.
  private struct AnchoringParser: MarkupParser {
    let anchors: [String: String]

    func attributedString(for input: String) throws -> AttributedString {
      var content = try AttributedStringMarkdownParser.markdown().attributedString(for: input)
      for (name, phrase) in anchors {
        guard let range = content.range(of: phrase) else { continue }
        content[range].textual.textAnchor = name
      }
      return content
    }
  }
#endif
