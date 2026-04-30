@testable import FlipNFlixIOS
import Foundation
import XCTest

@MainActor
final class DetailViewModelTests: XCTestCase {
    func testInitialStateUsesProvidedItemBeforeLoading() {
        let initialItem = makeDetailItem(id: 1, title: "Initial Title")
        let viewModel = DetailViewModel(
            item: initialItem,
            service: MockDetailMovieService(results: [])
        )

        XCTAssertEqual(viewModel.item, initialItem)
        XCTAssertEqual(viewModel.title, "Initial Title")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadIfNeededWhenServiceSucceedsRefreshesItem() async {
        let initialItem = makeDetailItem(id: 1, title: "Initial Title")
        let refreshedItem = makeDetailItem(
            id: 1,
            title: "Refreshed Title",
            overview: "Updated overview.",
            voteAverage: 9.1
        )
        let viewModel = DetailViewModel(
            item: initialItem,
            service: MockDetailMovieService(results: [.success(refreshedItem)])
        )

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.item, refreshedItem)
        XCTAssertEqual(viewModel.title, "Refreshed Title")
        XCTAssertEqual(viewModel.overviewText, "Updated overview.")
        XCTAssertEqual(viewModel.ratingText, "9.1")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadIfNeededWhenServiceFailsPreservesInitialItemAndPublishesError() async {
        let initialItem = makeDetailItem(id: 1, title: "Initial Title")
        let viewModel = DetailViewModel(
            item: initialItem,
            service: MockDetailMovieService(results: [.failure(.failed)])
        )

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.item, initialItem)
        XCTAssertEqual(viewModel.title, "Initial Title")
        XCTAssertEqual(viewModel.errorMessage, DetailTestError.failed.errorDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRetryCanRecoverAfterFailure() async {
        let initialItem = makeDetailItem(id: 1, title: "Initial Title")
        let refreshedItem = makeDetailItem(id: 1, title: "Recovered Title")
        let viewModel = DetailViewModel(
            item: initialItem,
            service: MockDetailMovieService(results: [
                .failure(.failed),
                .success(refreshedItem)
            ])
        )

        await viewModel.loadIfNeeded()
        await viewModel.retry()

        XCTAssertEqual(viewModel.item, refreshedItem)
        XCTAssertEqual(viewModel.title, "Recovered Title")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

private final class MockDetailMovieService: MovieServiceProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var results: [Result<MediaItem, DetailTestError>]

    init(results: [Result<MediaItem, DetailTestError>]) {
        self.results = results
    }

    func fetchPopularMovies() async throws -> [MediaItem] {
        []
    }

    func fetchTrendingMedia() async throws -> [MediaItem] {
        []
    }

    func fetchTopRatedMovies() async throws -> [MediaItem] {
        []
    }

    func fetchMediaDetail(id: Int, mediaType: MediaType) async throws -> MediaItem {
        let result = lock.withLock {
            results.isEmpty ? nil : results.removeFirst()
        }

        switch result {
        case let .success(item):
            return item
        case let .failure(error):
            throw error
        case .none:
            return makeDetailItem(id: id, mediaType: mediaType, title: "Fallback Detail")
        }
    }
}

private enum DetailTestError: LocalizedError, Sendable {
    case failed

    var errorDescription: String? {
        "Detail service failure"
    }
}

private func makeDetailItem(
    id: Int,
    mediaType: MediaType = .movie,
    title: String,
    overview: String = "Overview",
    voteAverage: Double = 8.0
) -> MediaItem {
    MediaItem(
        id: id,
        mediaType: mediaType,
        title: title,
        overview: overview,
        voteAverage: voteAverage,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-01-01"
    )
}
