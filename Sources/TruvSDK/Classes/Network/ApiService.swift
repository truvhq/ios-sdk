import Foundation

final class APIService {

    func invokeCallback(url: String, method: String, data: String, headers: [String: String]) async throws {
        guard let parsedUrl = URL(string: url) else { return }

        var request = URLRequest(url: parsedUrl)

        request.httpMethod = method
        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }

        request.httpBody = data.data(using: .utf8)

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    }

    func downloadScript(url: String) async throws -> String? {
        guard let parsedUrl = URL(string: url) else { return nil }
        let request = URLRequest(url: parsedUrl)

        let config = URLSessionConfiguration.ephemeral
        config.urlCache = nil
        let session = URLSession(configuration: config)

        let (responseData, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                return nil
            }
        }

        return String(decoding: responseData, as: UTF8.self)
    }
}
