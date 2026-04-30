@testable import FlipNFlixIOS
import XCTest

@MainActor
final class FlipNFlixIOSTests: XCTestCase {
    func testLoadIfNeededWhenServiceSucceedsPublishesExpectedSections() async {
        let popularMovie = makeMediaItem(id: 1, title: "Popular Movie")
        let trendingShow = makeMediaItem(id: 2, mediaType: .tv, title: "Trending Show")
        let topRatedMovie = makeMediaItem(id: 3, title: "Top Rated Movie")

        let service = MockMovieService(
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
        let service = MockMovieService(error: .failed)
        let viewModel = HomeViewModel(service: service)

        await viewModel.retry()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.sections.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, TestError.failed.errorDescription)
        XCTAssertFalse(viewModel.isEmpty)
    }
}

private struct MockMovieService: MovieServiceProtocol {
    let popularMovies: [MediaItem]
    let trendingMedia: [MediaItem]
    let topRatedMovies: [MediaItem]
    let error: TestError?

    init(
        popularMovies: [MediaItem] = [],
        trendingMedia: [MediaItem] = [],
        topRatedMovies: [MediaItem] = [],
        error: TestError? = nil
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
            ?? makeMediaItem(id: id, mediaType: mediaType, title: "Detail")
    }
}

private enum TestError: LocalizedError, Sendable {
    case failed

    var errorDescription: String? {
        "Mock service failure"
    }
}

private func makeMediaItem(
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
