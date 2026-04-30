@testable import FlipNFlixIOS
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadIfNeededWhenServiceSucceedsPublishesExpectedSections() async {
        let popularMovie = makeHomeMediaItem(id: 1, title: "Popular Movie")
        let trendingShow = makeHomeMediaItem(id: 2, mediaType: .tv, title: "Trending Show")
        let topRatedMovie = makeHomeMediaItem(id: 3, title: "Top Rated Movie")

        let service = MockHomeMovieService(
            popularMovies: [popularMovie],
            trendingMedia: [trendingShow],
            topRatedMovies: [topRatedMovie]
        )
        let viewModel = HomeViewModel(service: service)

        await viewModel.loadIfNeeded()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.sections.map(\.title), ["Popular", "Trending", "Top Rated"])
        XCTAssertEqual(viewModel.sections[0].items, [popularMovie])
        XCTAssertEqual(viewModel.sections[1].items, [trendingShow])
        XCTAssertEqual(viewModel.sections[2].items, [topRatedMovie])
    }

    func testRetryWhenServiceFailsClearsSectionsAndPublishesError() async {
        let service = MockHomeMovieService(error: .failed)
        let viewModel = HomeViewModel(service: service)

        await viewModel.retry()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.sections.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, HomeTestError.failed.errorDescription)
        XCTAssertFalse(viewModel.isEmpty)
    }

    func testRetryWhenRefreshFailsPreservesExistingSectionsAndPublishesError() async {
        let popularMovie = makeHomeMediaItem(id: 1, title: "Popular Movie")
        let refreshedMovie = makeHomeMediaItem(id: 2, title: "Refreshed Movie")
        let service = SequencedHomeMovieService(
            popularResults: [
                .success([popularMovie]),
                .failure(.failed),
                .success([refreshedMovie])
            ],
            trendingResults: [
                .success([]),
                .failure(.failed),
                .success([])
            ],
            topRatedResults: [
                .success([]),
                .failure(.failed),
                .success([])
            ]
        )
        let viewModel = HomeViewModel(service: service)

        await viewModel.loadIfNeeded()
        let loadedSections = viewModel.sections
        await viewModel.retry()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.sections, loadedSections)
        XCTAssertEqual(viewModel.errorMessage, HomeTestError.failed.errorDescription)

        await viewModel.retry()

        XCTAssertEqual(viewModel.sections[0].items, [refreshedMovie])
        XCTAssertNil(viewModel.errorMessage)
    }
}

private struct MockHomeMovieService: MovieServiceProtocol {
    let popularMovies: [MediaItem]
    let trendingMedia: [MediaItem]
    let topRatedMovies: [MediaItem]
    let error: HomeTestError?

    init(
        popularMovies: [MediaItem] = [],
        trendingMedia: [MediaItem] = [],
        topRatedMovies: [MediaItem] = [],
        error: HomeTestError? = nil
    ) {
        self.popularMovies = popularMovies
        self.trendingMedia = trendingMedia
        self.topRatedMovies = topRatedMovies
        self.error = error
    }

    func fetchPopularMovies() async throws -> [MediaItem] {
        if let error { throw error }
        return popularMovies
    }

    func fetchTrendingMedia() async throws -> [MediaItem] {
        if let error { throw error }
        return trendingMedia
    }

    func fetchTopRatedMovies() async throws -> [MediaItem] {
        if let error { throw error }
        return topRatedMovies
    }

    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem {
        if let error { throw error }

        return popularMovies.first { $0.id == id }
            ?? trendingMedia.first { $0.id == id }
            ?? topRatedMovies.first { $0.id == id }
            ?? makeHomeMediaItem(id: id, mediaType: mediaType, title: "Detail")
    }
}

private enum HomeTestError: LocalizedError, Sendable {
    case failed

    var errorDescription: String? {
        "Mock service failure"
    }
}

private final class SequencedHomeMovieService: MovieServiceProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var popularResults: [Result<[MediaItem], HomeTestError>]
    private var trendingResults: [Result<[MediaItem], HomeTestError>]
    private var topRatedResults: [Result<[MediaItem], HomeTestError>]

    init(
        popularResults: [Result<[MediaItem], HomeTestError>],
        trendingResults: [Result<[MediaItem], HomeTestError>],
        topRatedResults: [Result<[MediaItem], HomeTestError>]
    ) {
        self.popularResults = popularResults
        self.trendingResults = trendingResults
        self.topRatedResults = topRatedResults
    }

    func fetchPopularMovies() async throws -> [MediaItem] {
        try nextResult(from: \.popularResults)
    }

    func fetchTrendingMedia() async throws -> [MediaItem] {
        try nextResult(from: \.trendingResults)
    }

    func fetchTopRatedMovies() async throws -> [MediaItem] {
        try nextResult(from: \.topRatedResults)
    }

    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem {
        makeHomeMediaItem(id: id, mediaType: mediaType, title: "Detail")
    }

    private func nextResult(
        from keyPath: ReferenceWritableKeyPath<SequencedHomeMovieService, [Result<[MediaItem], HomeTestError>]>
    ) throws -> [MediaItem] {
        let result = lock.withLock {
            self[keyPath: keyPath].isEmpty ? nil : self[keyPath: keyPath].removeFirst()
        }

        switch result {
        case let .success(items):
            return items
        case let .failure(error):
            throw error
        case .none:
            return []
        }
    }
}

private func makeHomeMediaItem(
    id: Int,
    mediaType: MediaType = .movie,
    title: String
) -> MediaItem {
    MediaItem(
        id: id,
        mediaType: mediaType,
        title: title,
        overview: "Overview for \(title)",
        voteAverage: 8.0,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-01-01"
    )
}
