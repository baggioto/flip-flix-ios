import SwiftUI

struct MediaPosterCard: View, Equatable {
    let item: MediaItem

    static func == (lhs: MediaPosterCard, rhs: MediaPosterCard) -> Bool {
        lhs.item == rhs.item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: item.posterURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    MediaImagePlaceholder(style: .poster, state: .failed)
                case .empty:
                    MediaImagePlaceholder(style: .poster, state: .loading)
                @unknown default:
                    MediaImagePlaceholder(style: .poster)
                }
            }
            .frame(width: 132, height: 198)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityHidden(true)

            Text(item.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(width: 132, height: 36, alignment: .topLeading)
        }
        .contentShape(Rectangle())
    }
}

private extension MediaItem {
    var posterURL: URL? {
        ImageURLBuilder().url(for: posterPath, size: .poster)
    }
}
