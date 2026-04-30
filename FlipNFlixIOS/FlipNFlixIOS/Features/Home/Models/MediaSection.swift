import Foundation

struct MediaSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let items: [MediaItem]

    init(title: String, items: [MediaItem]) {
        self.id = title
        self.title = title
        self.items = items
    }
}
