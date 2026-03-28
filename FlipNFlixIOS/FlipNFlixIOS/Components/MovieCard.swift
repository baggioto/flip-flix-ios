//
//  MovieCard.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import SwiftUI

struct MovieCard: View {
    let movie: Movie

    var body: some View {
        VStack {
            AsyncImage(url: movie.posterURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 180)
            .cornerRadius(8)

            Text(movie.title)
                .font(.caption)
                .frame(width: 120, height: 40)
                .foregroundColor(.black)
        }
    }
}
