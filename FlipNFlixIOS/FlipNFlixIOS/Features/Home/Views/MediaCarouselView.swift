import SwiftUI

struct MediaCarouselView: View {
    let section: MediaSection
    let detailViewModelFactory: DetailViewModelFactory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title2.bold())
                .padding(.horizontal, 16)

            if section.items.isEmpty {
                EmptyCarouselRow(sectionTitle: section.title)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(section.items) { item in
                            NavigationLink {
                                DetailView(viewModel: detailViewModelFactory(item))
                            } label: {
                                MediaPosterCard(item: item)
                                    .equatable()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

private struct EmptyCarouselRow: View {
    let sectionTitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "film.stack")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text("No titles available")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(sectionTitle) will appear here when the catalog has results.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
