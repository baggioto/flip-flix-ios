import Combine
import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    let item: MediaItem

    init(item: MediaItem) {
        self.item = item
    }

    var title: String {
        item.title
    }

    var ratingText: String {
        String(format: "%.1f", item.voteAverage)
    }

    var releaseDateText: String {
        guard let releaseDate = item.releaseDate, releaseDate.isEmpty == false else {
            return "Unknown"
        }

        return releaseDate
    }

    var mediaTypeText: String {
        item.mediaType.displayName
    }

    var overviewText: String {
        item.overview.isEmpty ? "No overview available." : item.overview
    }
}

private extension MediaType {
    var displayName: String {
        switch self {
        case .movie:
            return "Movie"
        case .tv:
            return "TV Show"
        case .person:
            return "Person"
        case .unknown:
            return "Unknown"
        }
    }
}
