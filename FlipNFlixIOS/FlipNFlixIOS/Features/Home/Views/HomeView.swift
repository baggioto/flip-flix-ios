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
        } else if viewModel.isEmpty {
            EmptyStateView {
                Task { await viewModel.retry() }
            }
        } else if viewModel.sections.isEmpty == false {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    if viewModel.isRefreshing {
                        InlineRefreshStateView()
                            .padding(.horizontal, 16)
                    } else if let errorMessage = viewModel.errorMessage {
                        InlineRefreshErrorView(message: errorMessage) {
                            Task { await viewModel.retry() }
                        }
                        .padding(.horizontal, 16)
                    }

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
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.retry() }
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

private struct InlineRefreshStateView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)

            Text("Refreshing titles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

private struct InlineRefreshErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Unable to refresh titles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button("Retry", action: retry)
                .font(.caption.weight(.semibold))
                .buttonStyle(.borderless)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
