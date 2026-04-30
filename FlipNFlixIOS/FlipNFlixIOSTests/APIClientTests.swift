@testable import FlipNFlixIOS
import Foundation
import XCTest

@MainActor
final class APIClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.reset()
    }

    func testRequestWhenResponseSucceedsDecodesJSON() async throws {
        let expectedData = Data("""
        {
          "results": [
            {
              "id": 1,
              "media_type": "movie",
              "title": "Midnight Signal",
              "overview": "A signal from tomorrow.",
              "vote_average": 8.2,
              "poster_path": "/poster.jpg",
              "backdrop_path": "/backdrop.jpg",
              "release_date": "2026-03-14"
            }
          ]
        }
        """.utf8)
        let client = makeAPIClient(
            response: HTTPURLResponse(
                url: baseURL.appending(path: APIEndpoint.popularMovies.path),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            data: expectedData
        )

        let response = try await client.request(.popularMovies, as: MediaResponse.self)
        let results = response.results
        let firstResult = results.first

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(firstResult?.id, 1)
        XCTAssertEqual(firstResult?.title, "Midnight Signal")
        XCTAssertEqual(firstResult?.voteAverage, 8.2)
    }

    func testRequestWhenAccessTokenIsMissingThrowsMissingAccessToken() async {
        let client = APIClient(
            baseURL: baseURL,
            session: makeURLSession(),
            accessTokenProvider: { nil },
            maxRetryCount: 0
        )

        do {
            _ = try await client.request(.popularMovies, as: MediaResponse.self)
            XCTFail("Expected request to throw missingAccessToken.")
        } catch {
            XCTAssertEqual(error as? APIError, .missingAccessToken)
        }
    }

    func testRequestWhenServerReturnsErrorMapsAPIError() async {
        let errorData = Data("""
        {
          "status_message": "Something went wrong."
        }
        """.utf8)
        let client = makeAPIClient(
            response: HTTPURLResponse(
                url: baseURL.appending(path: APIEndpoint.popularMovies.path),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            ),
            data: errorData
        )

        do {
            _ = try await client.request(.popularMovies, as: MediaResponse.self)
            XCTFail("Expected request to throw server error.")
        } catch {
            XCTAssertEqual(error as? APIError, .server(statusCode: 500, message: "Something went wrong."))
        }
    }
}

private let baseURL = URL(string: "https://example.com/3")!

private func makeAPIClient(
    response: HTTPURLResponse?,
    data: Data = Data()
) -> APIClient {
    MockURLProtocol.stub(response: response, data: data)

    return APIClient(
        baseURL: baseURL,
        session: makeURLSession(),
        accessTokenProvider: { "test-token" },
        maxRetryCount: 0
    )
}

private func makeURLSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    private struct Stub: Sendable {
        let response: URLResponse?
        let data: Data
        let error: Error?
    }

    private static let lock = NSLock()
    private static var stub: Stub?

    static func stub(
        response: URLResponse?,
        data: Data = Data(),
        error: Error? = nil
    ) {
        lock.withLock {
            stub = Stub(response: response, data: data, error: error)
        }
    }

    static func reset() {
        lock.withLock {
            stub = nil
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let stub = Self.lock.withLock { Self.stub }

        if let error = stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
