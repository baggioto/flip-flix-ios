//
//  FlipNFlixIOSApp.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import SwiftUI

@main
struct FlipNFlixIOSApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(service: PreviewMovieService()))
        }
    }
}
