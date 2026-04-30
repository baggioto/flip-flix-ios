import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel

    init(viewModel: DetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                posterImage

                VStack(alignment: .leading, spacing: 16) {
                    titleBlock
                    metadata
                    loadingIndicator
                    errorBanner
                    overview
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private var posterImage: some View {
        AsyncImage(url: viewModel.item.detailImageURL) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                DetailImagePlaceholder()
            case .empty:
                ZStack {
                    DetailImagePlaceholder()
                    ProgressView()
                        .tint(.white)
                }
            @unknown default:
                DetailImagePlaceholder()
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .accessibilityHidden(true)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.overviewText)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var metadata: some View {
        HStack(spacing: 10) {
            MetadataPill(systemImage: "star.fill", text: viewModel.ratingText)
            MetadataPill(systemImage: "calendar", text: viewModel.releaseDateText)
            MetadataPill(systemImage: "play.rectangle", text: viewModel.mediaTypeText)
        }
        .font(.caption.weight(.semibold))
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isLoading {
            ProgressView()
                .controlSize(.small)
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 8) {
                Label("Unable to refresh details", systemImage: "exclamationmark.triangle")
                    .font(.subheadline.weight(.semibold))

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Try Again") {
                    Task { await viewModel.retry() }
                }
                .buttonStyle(.bordered)
            }
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)

            Text(viewModel.overviewText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MetadataPill: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.thinMaterial, in: Capsule())
    }
}

private struct DetailImagePlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.25))
            .overlay {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 320)
    }
}

private extension MediaItem {
    var detailImageURL: URL? {
        if let backdropPath, backdropPath.isEmpty == false {
            return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
        }

        guard let posterPath, posterPath.isEmpty == false else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
}

#Preview {
    NavigationStack {
        DetailView(
            viewModel: DetailViewModel(
                item: MediaItem(
                    id: 1,
                    mediaType: .movie,
                    title: "Midnight Signal",
                    overview: "A burned-out engineer discovers a broadcast from tomorrow and has one night to prevent a citywide blackout.",
                    voteAverage: 8.2,
                    posterPath: "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg",
                    backdropPath: "/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg",
                    releaseDate: "2026-03-14"
                ),
                service: PreviewMovieService()
            )
        )
    }
}
