import SwiftUI

struct MediaImagePlaceholder: View {
    enum Style {
        case poster
        case backdrop
    }

    enum LoadState {
        case loading
        case failed
        case unavailable
    }

    let style: Style
    let state: LoadState

    init(style: Style, state: LoadState = .unavailable) {
        self.style = style
        self.state = state
    }

    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.22))
            .overlay {
                overlayContent
            }
    }

    @ViewBuilder
    private var overlayContent: some View {
        switch state {
        case .loading:
            ProgressView()
                .controlSize(progressViewControlSize)
                .tint(.white)
        case .failed:
            Image(systemName: "exclamationmark.triangle")
                .font(iconFont)
                .foregroundStyle(.secondary)
        case .unavailable:
            Image(systemName: "film")
                .font(iconFont)
                .foregroundStyle(.secondary)
        }
    }

    private var iconFont: Font {
        switch style {
        case .poster:
            .title2
        case .backdrop:
            .largeTitle
        }
    }

    private var progressViewControlSize: ControlSize {
        switch style {
        case .poster:
            .small
        case .backdrop:
            .regular
        }
    }
}
