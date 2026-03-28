//
//  MovieResponse.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//


struct MovieResponse: Decodable {
    let results: [Movie]
}