//
//  MovieService.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import Combine

class MovieService {
    private let api = APIClient()
    
    func getMovies() -> AnyPublisher<[Movie], Error> {
        api.fetchMovies()
    }
}
