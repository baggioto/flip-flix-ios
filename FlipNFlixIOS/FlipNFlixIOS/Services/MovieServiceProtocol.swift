protocol MovieServiceProtocol: Sendable {
    func fetchPopularMovies() async throws -> [MediaItem]
    func fetchTrendingMedia() async throws -> [MediaItem]
    func fetchTopRatedMovies() async throws -> [MediaItem]
    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem
}
