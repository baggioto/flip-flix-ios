//
//  HomeView.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {

                    Text("Popular")
                        .font(.title)
                        .bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink {
                                    DetailView(movie: movie)
                                } label: {
                                    MovieCard(movie: movie)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.fetch()
            }
            .navigationTitle("FlipNFlix")
        }
    }
}
