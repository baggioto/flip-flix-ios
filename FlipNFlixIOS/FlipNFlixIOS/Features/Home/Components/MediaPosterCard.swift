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
                    PosterPlaceholder()
                case .empty:
                    ZStack {
                        PosterPlaceholder()
                        ProgressView()
                            .tint(.white)
                    }
                @unknown default:
                    PosterPlaceholder()
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

private struct PosterPlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.25))
            .overlay {
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
}

private extension MediaItem {
    var posterURL: URL? {
        guard let posterPath, posterPath.isEmpty == false else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
}
