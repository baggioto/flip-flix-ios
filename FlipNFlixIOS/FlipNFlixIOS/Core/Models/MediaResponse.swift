import Foundation

struct MediaResponse: Decodable, Sendable {
    let page: Int?
    let results: [MediaItem]
    let totalPages: Int?
    let totalResults: Int?
}
