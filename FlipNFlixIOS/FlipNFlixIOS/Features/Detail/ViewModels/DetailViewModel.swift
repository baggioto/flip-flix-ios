import Combine
import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var item: MediaItem
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: MovieServiceProtocol
    private var hasLoaded = false

    init(item: MediaItem, service: MovieServiceProtocol) {
        self.item = item
        self.service = service
    }

    func loadIfNeeded() async {
        guard hasLoaded == false else { return }
        await loadDetail()
    }

    func retry() async {
        hasLoaded = false
        await loadDetail()
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

    private func loadDetail() async {
        isLoading = true
        errorMessage = nil

        do {
            item = try await service.fetchMediaDetail(id: item.id, mediaType: item.mediaType)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
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
