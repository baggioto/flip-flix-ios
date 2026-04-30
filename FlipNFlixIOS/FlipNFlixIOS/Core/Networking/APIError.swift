import Foundation

enum APIError: Error, Equatable, LocalizedError {
    case invalidURL
    case missingAccessToken
    case invalidResponse
    case unauthorized
    case rateLimited
    case server(statusCode: Int, message: String?)
    case decoding(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .missingAccessToken:
            return "Missing API access token."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unauthorized:
            return "The API access token is invalid or expired."
        case .rateLimited:
            return "Too many requests. Please try again shortly."
        case let .server(statusCode, message):
            return message ?? "Server error (\(statusCode))."
        case let .decoding(message):
            return "Unable to decode the response: \(message)"
        case let .transport(message):
            return "Network error: \(message)"
        }
    }
}
