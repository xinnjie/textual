import SwiftUI

// MARK: - Overview
//
// BlockVStack arranges blocks vertically with CSS-style margin collapsing behavior. Adjacent
// blocks' top and bottom spacing collapses by taking the maximum value rather than summing,
// matching how CSS margins work.
//
// List items can override block spacing with environment-driven list item spacing for consistent
// spacing within lists regardless of individual block preferences.

extension StructuredText {
  struct BlockVStack<Content: View>: View {
    @Environment(\.multilineTextAlignment) private var textAlignment

    @State private var alignments: [Int: TextAlignment] = [:]
    @State private var spacings: [Int: BlockSpacing] = [:]

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
      self.content = content()
    }

    var body: some View {
      Group(subviews: content) { children in
        LazyVStack(alignment: .leading, spacing: 0) {
          ForEach(Array(zip(children.indices, children)), id: \.0) { index, child in
            BlockLayoutView(child, index: index) { index, spacing in
              spacings[index] = spacing
            } alignmentChanged: { index, alignment in
              alignments[index] = alignment
            }
            .padding(.top, spacing(before: index))
            .frame(maxWidth: .infinity, alignment: alignment(for: index))
          }
        }
      }
    }

    private func spacing(before index: Int) -> CGFloat {
      guard index > 0 else { return 0 }

      let previousBottom = spacings[index - 1]?.bottom
      let currentTop = spacings[index]?.top

      return [previousBottom, currentTop].compactMap(\.self).max() ?? 0
    }

    private func alignment(for index: Int) -> Alignment {
      switch alignments[index] ?? textAlignment {
      case .leading:
        return .leading
      case .center:
        return .center
      case .trailing:
        return .trailing
      }
    }
  }
}

extension StructuredText {
  struct BlockAlignmentKey: LayoutValueKey, PreferenceKey {
    static let defaultValue: TextAlignment? = nil

    static func reduce(value: inout TextAlignment?, nextValue: () -> TextAlignment?) {
      value = nextValue() ?? value
    }
  }

  fileprivate struct BlockLayoutView<Content: View>: View {
    @Environment(\.listItemSpacingEnabled) private var listItemSpacingEnabled
    @Environment(\.resolvedListItemSpacing) private var resolvedListItemSpacing

    @State private var blockSpacing = BlockSpacing()

    private let content: Content
    private let index: Int
    private let alignmentChanged: (Int, TextAlignment?) -> Void
    private let spacingChanged: (Int, BlockSpacing) -> Void

    init(
      _ content: Content,
      index: Int,
      spacingChanged: @escaping (Int, BlockSpacing) -> Void,
      alignmentChanged: @escaping (Int, TextAlignment?) -> Void
    ) {
      self.content = content
      self.index = index
      self.spacingChanged = spacingChanged
      self.alignmentChanged = alignmentChanged
    }

    var body: some View {
      content
        .onPreferenceChange(BlockSpacingKey.self) { @MainActor value in
          let spacing = listItemSpacingEnabled ? resolvedListItemSpacing : value
          blockSpacing = spacing
          spacingChanged(index, spacing)
        }
        .onPreferenceChange(BlockAlignmentKey.self) { @MainActor value in
          alignmentChanged(index, value)
        }
        .layoutValue(key: BlockSpacingKey.self, value: blockSpacing)
    }
  }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
  @Previewable @State var textAlignment = TextAlignment.leading
  @Previewable @State var blockSpacing: CGFloat = 1

  VStack {
    GroupBox {
      Picker("Text Alignment", selection: $textAlignment) {
        Text("Leading").tag(TextAlignment.leading)
        Text("Center").tag(TextAlignment.center)
        Text("Trailing").tag(TextAlignment.trailing)
      }
      .pickerStyle(.segmented)
      HStack {
        Text("2nd / 3rd Spacing")
        Slider(value: $blockSpacing, in: 0...3)
      }
    }
    Spacer()
    StructuredText.BlockVStack {
      Text(
        """
        Listen to your sister, Morty. To live is to risk it all, otherwise you’re just an inert \
        chunk of randomly assembled molecules drifting wherever the universe blows you.
        """
      )
      .textual.blockSpacing(.fontScaled(bottom: 1))
      Text(
        """
        Listen, Morty, I hate to break it to you but what people call "love" is just a chemical \
        reaction that compels animals to breed. It hits hard, Morty, then it slowly fades, \
        leaving you stranded in a failing marriage. I did it. Your parents are gonna do it. \
        Break the cycle, Morty. Rise above. Focus on science.
        """
      )
      .textual.blockSpacing(.fontScaled(bottom: blockSpacing))
      Text(
        """
        Wow, I really Cronenberged up the whole place, huh Morty? Just a bunch a Cronenbergs \
        walkin' around.
        """
      )
      .textual.blockSpacing(.fontScaled(top: 1, bottom: 1))
    }
    .border(Color.red)
    Spacer()
  }
  .multilineTextAlignment(textAlignment)
  .padding()
}
