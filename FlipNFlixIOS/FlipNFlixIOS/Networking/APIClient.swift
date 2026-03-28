//
//  APIClient.swift
//  FlipNFlixIOS
//
//  Created by Felipe Baggioto Przybylski   on 27/03/26.
//


import Combine
import Foundation

private struct TMDBErrorResponse: Decodable, Error {
    let status_message: String?
    let status_code: Int?
    let success: Bool?
}

private func debugPrintData(_ data: Data) -> String {
    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
       let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
       let string = String(data: pretty, encoding: .utf8) {
        return string
    }
    return String(data: data, encoding: .utf8) ?? "<non-utf8 data>"
}

private enum Secrets {
    static var tmdbAccessToken: String? {
        Bundle.main.object(forInfoDictionaryKey: "TMDBAccessToken") as? String
    }
}

class APIClient {
    
    func fetchMovies() -> AnyPublisher<[Movie], Error> {
        guard let token = Secrets.tmdbAccessToken, token.isEmpty == false else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        var components = URLComponents(string: "https://api.themoviedb.org/3/discover/movie")!
        components.queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let requestID = UUID()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                print("[API][\(requestID)] -> GET \(request.url?.absoluteString ?? "<nil>")")
            }, receiveOutput: { output in
                if let response = output.response as? HTTPURLResponse {
                    print("[API][\(requestID)] <- status: \(response.statusCode)")
                }
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("[API][\(requestID)] ✖︎ Transport error: \(error)")
                } else {
                    print("[API][\(requestID)] ✓ Completed")
                }
            })
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                // Log body for non-2xx to help debugging
                if !(200...299).contains(http.statusCode) {
                    let bodyPreview = debugPrintData(output.data)
                    print("[API][\(requestID)] ❗️HTTP \(http.statusCode) body:\n\(bodyPreview)")
                    // Try to decode TMDB error
                    if let tmdbError = try? JSONDecoder().decode(TMDBErrorResponse.self, from: output.data) {
                        let message = tmdbError.status_message ?? "Unknown TMDB error"
                        let code = tmdbError.status_code ?? http.statusCode
                        throw NSError(domain: "TMDB", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                    }
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .mapError { error -> Error in
                print("[API][\(requestID)] ✖︎ Pipeline error: \(error)")
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

