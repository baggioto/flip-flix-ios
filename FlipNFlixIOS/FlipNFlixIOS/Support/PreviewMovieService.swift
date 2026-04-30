struct PreviewMovieService: MovieServiceProtocol {
    func fetchPopularMovies() async throws -> [MediaItem] {
        MediaItem.previewItems
    }

    func fetchTrendingMedia() async throws -> [MediaItem] {
        []
    }

    func fetchTopRatedMovies() async throws -> [MediaItem] {
        []
    }

    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem {
        MediaItem.previewItems.first { $0.id == id } ?? MediaItem.previewItems[0]
    }
}

private extension MediaItem {
    static let previewItems = [
        MediaItem(
            id: 1,
            mediaType: .movie,
            title: "Midnight Signal",
            overview: "A burned-out engineer discovers a broadcast from tomorrow and has one night to prevent a citywide blackout.",
            voteAverage: 8.2,
            posterPath: "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg",
            backdropPath: nil,
            releaseDate: "2026-03-14"
        ),
        MediaItem(
            id: 2,
            mediaType: .movie,
            title: "The Long Orbit",
            overview: "A maintenance crew on a drifting station finds a missing shuttle and a message that changes the mission.",
            voteAverage: 7.8,
            posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
            backdropPath: nil,
            releaseDate: "2025-11-21"
        ),
        MediaItem(
            id: 3,
            mediaType: .tv,
            title: "Northline",
            overview: "Detectives on a remote rail route unravel a conspiracy hiding in the gaps between stations.",
            voteAverage: 7.6,
            posterPath: "/8YFL5QQVPy3AgrEQxNYVSgiPEbe.jpg",
            backdropPath: nil,
            releaseDate: "2025-10-02"
        )
    ]
}
