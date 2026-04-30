//
//  FlipNFlixIOSApp.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//

import SwiftUI

@main
struct FlipNFlixIOSApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: dependencies.makeHomeViewModel())
        }
    }
}
