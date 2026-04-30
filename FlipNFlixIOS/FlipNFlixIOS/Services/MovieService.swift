struct MovieService: MovieServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPopularMovies() async throws -> [MediaItem] {
        try await fetchMedia(from: .popularMovies)
    }

    func fetchTrendingMedia() async throws -> [MediaItem] {
        let items = try await fetchMedia(from: .trending)
        return items.filter { $0.mediaType != .person }
    }

    func fetchTopRatedMovies() async throws -> [MediaItem] {
        try await fetchMedia(from: .topRatedMovies)
    }

    private func fetchMedia(from endpoint: APIEndpoint) async throws -> [MediaItem] {
        let response = try await apiClient.request(endpoint, as: MediaResponse.self)
        return response.results
    }
}
