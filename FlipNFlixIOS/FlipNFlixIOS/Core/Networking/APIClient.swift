import Foundation

struct APIClient: APIClientProtocol {
    private nonisolated let baseURL: URL
    private nonisolated let session: URLSession
    private nonisolated let accessTokenProvider: @Sendable () -> String?
    private nonisolated let maxRetryCount: Int

    init(
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        session: URLSession = .shared,
        accessTokenProvider: @escaping @Sendable () -> String? = {
            Bundle.main.object(forInfoDictionaryKey: "TMDBAccessToken") as? String
        },
        maxRetryCount: Int = 2
    ) {
        self.baseURL = baseURL
        self.session = session
        self.accessTokenProvider = accessTokenProvider
        self.maxRetryCount = maxRetryCount
    }

    nonisolated func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        as responseType: Response.Type
    ) async throws -> Response {
        guard let accessToken = accessTokenProvider(), accessToken.isEmpty == false else {
            throw APIError.missingAccessToken
        }

        let request = try makeRequest(for: endpoint, accessToken: accessToken)
        let data = try await perform(request)

        do {
            return try Self.decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

    private nonisolated func makeRequest(for endpoint: APIEndpoint, accessToken: String) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appending(path: endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private nonisolated func perform(_ request: URLRequest) async throws -> Data {
        var lastError: APIError?

        for attempt in 0...maxRetryCount {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if (200...299).contains(httpResponse.statusCode) {
                    return data
                }

                let apiError = mapHTTPError(statusCode: httpResponse.statusCode, data: data)
                guard shouldRetry(apiError, attempt: attempt) else {
                    throw apiError
                }

                lastError = apiError
                try await waitBeforeRetry(attempt: attempt)
            } catch let apiError as APIError {
                guard shouldRetry(apiError, attempt: attempt) else {
                    throw apiError
                }

                lastError = apiError
                try await waitBeforeRetry(attempt: attempt)
            } catch {
                let apiError = APIError.transport(error.localizedDescription)
                guard shouldRetry(apiError, attempt: attempt) else {
                    throw apiError
                }

                lastError = apiError
                try await waitBeforeRetry(attempt: attempt)
            }
        }

        throw lastError ?? APIError.invalidResponse
    }

    private nonisolated func mapHTTPError(statusCode: Int, data: Data) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 429:
            return .rateLimited
        default:
            return .server(statusCode: statusCode, message: Self.errorMessage(from: data))
        }
    }

    private nonisolated func shouldRetry(_ error: APIError, attempt: Int) -> Bool {
        guard attempt < maxRetryCount else { return false }

        switch error {
        case .rateLimited, .transport:
            return true
        case let .server(statusCode, _):
            return (500...599).contains(statusCode)
        default:
            return false
        }
    }

    private nonisolated func waitBeforeRetry(attempt: Int) async throws {
        let delay = UInt64(pow(2.0, Double(attempt))) * 300_000_000
        try await Task.sleep(nanoseconds: delay)
    }

    private nonisolated static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    private nonisolated static func errorMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let dictionary = object as? [String: Any],
            let message = dictionary["status_message"] as? String
        else {
            return nil
        }

        return message
    }
}
