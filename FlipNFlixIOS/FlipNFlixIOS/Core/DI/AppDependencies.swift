import Foundation

struct AppDependencies {
    static let live = AppDependencies()

    private let apiClient: APIClientProtocol
    private let movieService: MovieServiceProtocol

    init(
        apiClient: APIClientProtocol = APIClient(),
        movieService: MovieServiceProtocol? = nil
    ) {
        self.apiClient = apiClient
        self.movieService = movieService ?? MovieService(apiClient: apiClient)
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(service: movieService)
    }

    @MainActor
    func makeDetailViewModel(item: MediaItem) -> DetailViewModel {
        DetailViewModel(item: item, service: movieService)
    }
}
