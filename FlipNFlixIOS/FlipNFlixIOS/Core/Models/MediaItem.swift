import Foundation

struct MediaItem: Identifiable, Decodable, Equatable, Sendable {
    let id: Int
    let mediaType: MediaType
    let title: String
    let overview: String
    let voteAverage: Double
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case title
        case name
        case overview
        case voteAverage
        case posterPath
        case backdropPath
        case releaseDate
        case firstAirDate
    }

    init(
        id: Int,
        mediaType: MediaType,
        title: String,
        overview: String,
        voteAverage: Double,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?
    ) {
        self.id = id
        self.mediaType = mediaType
        self.title = title
        self.overview = overview
        self.voteAverage = voteAverage
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        mediaType = try container.decodeIfPresent(MediaType.self, forKey: .mediaType) ?? .movie
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? "Untitled"
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
            ?? container.decodeIfPresent(String.self, forKey: .firstAirDate)
    }
}
