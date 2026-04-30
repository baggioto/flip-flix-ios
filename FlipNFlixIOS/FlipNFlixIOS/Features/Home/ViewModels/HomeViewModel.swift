import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var sections: [MediaSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: MovieServiceProtocol
    private var hasLoaded = false

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    var isEmpty: Bool {
        isLoading == false && errorMessage == nil && sections.allSatisfy(\.items.isEmpty)
    }

    func loadIfNeeded() async {
        guard hasLoaded == false else { return }
        await loadSections()
    }

    func retry() async {
        hasLoaded = false
        await loadSections()
    }

    private func loadSections() async {
        isLoading = true
        errorMessage = nil

        do {
            async let popularMovies = service.fetchPopularMovies()
            async let trendingMedia = service.fetchTrendingMedia()
            async let topRatedMovies = service.fetchTopRatedMovies()

            let loadedSections = try await [
                MediaSection(title: "Popular", items: popularMovies),
                MediaSection(title: "Trending", items: trendingMedia),
                MediaSection(title: "Top Rated", items: topRatedMovies)
            ]

            if sections != loadedSections {
                sections = loadedSections
            }

            hasLoaded = true
        } catch {
            sections = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
