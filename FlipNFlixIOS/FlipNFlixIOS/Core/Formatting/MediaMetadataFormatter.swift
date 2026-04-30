import Foundation

struct MediaMetadataFormatter: Sendable {
    func ratingText(for voteAverage: Double) -> String {
        String(format: "%.1f", voteAverage)
    }

    func releaseDateText(for releaseDate: String?) -> String {
        guard let releaseDate, releaseDate.isEmpty == false else {
            return "Unknown"
        }

        guard let date = Self.inputDateFormatter.date(from: releaseDate) else {
            return "Unknown"
        }

        return Self.outputDateFormatter.string(from: date)
    }

    func mediaTypeText(for mediaType: MediaType) -> String {
        switch mediaType {
        case .movie:
            return "Movie"
        case .tv:
            return "TV Show"
        case .person:
            return "Person"
        case .unknown:
            return "Unknown"
        }
    }
}

private extension MediaMetadataFormatter {
    static var inputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static var outputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
}
