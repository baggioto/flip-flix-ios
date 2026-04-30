import Foundation

struct ImageURLBuilder: Sendable {
    enum Size: String, Sendable {
        case poster = "w500"
        case backdrop = "w780"
    }

    private let baseURL: URL

    init(baseURL: URL = URL(string: "https://image.tmdb.org/t/p")!) {
        self.baseURL = baseURL
    }

    func url(for path: String?, size: Size) -> URL? {
        guard let path, path.isEmpty == false else { return nil }

        return baseURL
            .appending(path: size.rawValue)
            .appending(path: normalizedPath(path))
    }

    private func normalizedPath(_ path: String) -> String {
        path.hasPrefix("/") ? String(path.dropFirst()) : path
    }
}
