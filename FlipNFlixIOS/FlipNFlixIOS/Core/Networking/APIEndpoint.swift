import Foundation

enum APIEndpoint: Equatable, Sendable {
    case popularMovies
    case trending
    case topRatedMovies
    case movieDetail(id: Int)
    case tvDetail(id: Int)

    nonisolated var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .trending:
            return "/trending/all/week"
        case .topRatedMovies:
            return "/movie/top_rated"
        case let .movieDetail(id):
            return "/movie/\(id)"
        case let .tvDetail(id):
            return "/tv/\(id)"
        }
    }

    nonisolated var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
    }
}
