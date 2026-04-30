import Foundation

enum MediaType: String, Decodable, Equatable, Sendable {
    case movie
    case tv
    case person
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MediaType(rawValue: rawValue) ?? .unknown
    }
}
