//
//  DetailView.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import SwiftUI

struct DetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                AsyncImage(url: movie.posterURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)

                VStack(alignment: .leading, spacing: 16) {
                    Text(movie.title)
                        .font(.title)
                        .bold()

                    Text("⭐ \(movie.voteAverage, specifier: "%.1f")")
                        .font(.headline)

                    Text(movie.overview)
                        .font(.body)
                }
                .padding()
            }
        }
    }
}
