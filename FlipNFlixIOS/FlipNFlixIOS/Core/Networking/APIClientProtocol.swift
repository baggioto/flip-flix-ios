protocol APIClientProtocol: Sendable {
    nonisolated func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        as responseType: Response.Type
    ) async throws -> Response
}
