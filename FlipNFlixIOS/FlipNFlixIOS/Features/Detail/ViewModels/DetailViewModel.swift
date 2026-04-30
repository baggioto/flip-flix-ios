import Combine
import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var item: MediaItem
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: MovieServiceProtocol
    private let metadataFormatter: MediaMetadataFormatter
    private var hasLoaded = false

    init(
        item: MediaItem,
        service: MovieServiceProtocol,
        metadataFormatter: MediaMetadataFormatter = MediaMetadataFormatter()
    ) {
        self.item = item
        self.service = service
        self.metadataFormatter = metadataFormatter
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
        metadataFormatter.ratingText(for: item.voteAverage)
    }

    var releaseDateText: String {
        metadataFormatter.releaseDateText(for: item.releaseDate)
    }

    var mediaTypeText: String {
        metadataFormatter.mediaTypeText(for: item.mediaType)
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
