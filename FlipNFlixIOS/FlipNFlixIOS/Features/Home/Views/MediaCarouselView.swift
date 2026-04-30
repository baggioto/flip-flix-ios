import SwiftUI

struct MediaCarouselView: View {
    let section: MediaSection
    let detailViewModelFactory: DetailViewModelFactory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title2.bold())
                .padding(.horizontal, 16)

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
