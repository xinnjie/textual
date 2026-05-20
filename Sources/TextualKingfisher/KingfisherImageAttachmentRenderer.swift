import Kingfisher
import SwiftUI
import Textual

/// An image attachment renderer backed by Kingfisher.
public struct KingfisherImageAttachmentRenderer: ImageAttachmentRenderer {
  private let options: KingfisherOptionsInfo?

  public init(options: KingfisherOptionsInfo? = nil) {
    self.options = options
  }

  public func attachment(for request: ImageAttachmentRequest) async throws -> AnyAttachment {
    let resource = KF.ImageResource(downloadURL: request.url)
    let result = try await KingfisherManager.shared.retrieveImage(
      with: resource,
      options: options
    )

    let attachment: any Attachment = KingfisherImageAttachment(
      url: request.url,
      text: request.text,
      size: result.image.size,
      options: options
    )
    return AnyAttachment(attachment)
  }
}

extension ImageAttachmentRenderer where Self == KingfisherImageAttachmentRenderer {
  /// A Kingfisher-backed image renderer.
  public static func kingfisher(options: KingfisherOptionsInfo? = nil) -> Self {
    .init(options: options)
  }
}

private struct KingfisherImageAttachment: Attachment {
  var description: String {
    text
  }

  private let url: URL
  private let text: String
  private let size: CGSize
  private let options: KingfisherOptionsInfo?

  init(
    url: URL,
    text: String,
    size: CGSize,
    options: KingfisherOptionsInfo?
  ) {
    self.url = url
    self.text = text
    self.size = size
    self.options = options
  }

  var body: some View {
    let image = KFImage(url)
    image.options = KingfisherParsedOptionsInfo(options)

    return image
      .resizable()
      .aspectRatio(contentMode: .fit)
  }

  func sizeThatFits(_ proposal: ProposedViewSize, in _: TextEnvironmentValues) -> CGSize {
    guard let proposedWidth = proposal.width else {
      return size
    }

    let aspect = size.width / size.height
    let width = min(proposedWidth, size.width)
    let height = width / aspect

    return CGSize(width: width, height: height)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.url == rhs.url && lhs.text == rhs.text && lhs.size == rhs.size
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(url)
    hasher.combine(text)
    hasher.combine(size.width)
    hasher.combine(size.height)
  }
}
