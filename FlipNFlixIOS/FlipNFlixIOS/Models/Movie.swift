//
//  Movie.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import Foundation

struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let overview: String
    let voteAverage: Double
    let posterPath: String?

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}
