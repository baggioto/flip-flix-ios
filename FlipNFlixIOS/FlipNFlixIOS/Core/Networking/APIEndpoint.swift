import Foundation

enum APIEndpoint: Equatable, Sendable {
    case popularMovies
    case trending
    case topRatedMovies

    nonisolated var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .trending:
            return "/trending/all/week"
        case .topRatedMovies:
            return "/movie/top_rated"
        }
    }

    nonisolated var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
    }
}
