import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let detailViewModelFactory: DetailViewModelFactory

    init(
        viewModel: HomeViewModel,
        makeDetailViewModel: @escaping @MainActor @Sendable (MediaItem) -> DetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailViewModelFactory = DetailViewModelFactory(makeDetailViewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("FlipNFlix")
            .task {
                await viewModel.loadIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.sections.isEmpty {
            LoadingStateView()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.retry() }
            }
        } else if viewModel.isEmpty {
            EmptyStateView {
                Task { await viewModel.retry() }
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    ForEach(viewModel.sections) { section in
                        MediaCarouselView(
                            section: section,
                            detailViewModelFactory: detailViewModelFactory
                        )
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                await viewModel.retry()
            }
        }
    }
}

struct DetailViewModelFactory: Sendable {
    private let makeDetailViewModel: @MainActor @Sendable (MediaItem) -> DetailViewModel

    init(_ makeDetailViewModel: @escaping @MainActor @Sendable (MediaItem) -> DetailViewModel) {
        self.makeDetailViewModel = makeDetailViewModel
    }

    @MainActor
    func callAsFunction(_ item: MediaItem) -> DetailViewModel {
        makeDetailViewModel(item)
    }
}

private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading titles")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct EmptyStateView: View {
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No titles found", systemImage: "film.stack")
        } description: {
            Text("Try refreshing the catalog.")
        } actions: {
            Button("Refresh", action: retry)
        }
    }
}

private struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to load titles", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
        }
    }
}
