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

    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem {
        let endpoint: APIEndpoint

        switch mediaType {
        case .tv:
            endpoint = .tvDetail(id: id)
        case .movie, .unknown:
            endpoint = .movieDetail(id: id)
        case .person:
            throw APIError.invalidURL
        }

        let item = try await apiClient.request(endpoint, as: MediaItem.self)
        return item.withMediaType(mediaType == .unknown ? item.mediaType : mediaType)
    }

    private func fetchMedia(from endpoint: APIEndpoint) async throws -> [MediaItem] {
        let response = try await apiClient.request(endpoint, as: MediaResponse.self)
        return response.results
    }
}

private extension MediaItem {
    func withMediaType(_ mediaType: MediaType) -> MediaItem {
        MediaItem(
            id: id,
            mediaType: mediaType,
            title: title,
            overview: overview,
            voteAverage: voteAverage,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate
        )
    }
}
