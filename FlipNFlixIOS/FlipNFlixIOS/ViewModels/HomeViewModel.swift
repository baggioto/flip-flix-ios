import Combine

class HomeViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false

    private let service: MovieService
    private var cancellables = Set<AnyCancellable>()

    init(service: MovieService) {
        self.service = service
    }

    func fetch() {
        isLoading = true

        service
            .getMovies()
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] movies in
                    self?.movies = movies
                }
            )
            .store(in: &cancellables)
    }
}
