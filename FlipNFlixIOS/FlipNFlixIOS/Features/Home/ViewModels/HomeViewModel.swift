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
        await loadPopularMovies()
    }

    func retry() async {
        hasLoaded = false
        await loadPopularMovies()
    }

    private func loadPopularMovies() async {
        isLoading = true
        errorMessage = nil

        do {
            let popularMovies = try await service.fetchPopularMovies()
            sections = [
                MediaSection(title: "Popular", items: popularMovies)
            ]
            hasLoaded = true
        } catch {
            sections = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
