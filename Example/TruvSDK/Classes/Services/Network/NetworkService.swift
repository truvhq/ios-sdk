import Foundation

final class NetworkService {

    // MARK: - Public

    func getBridgeToken(accessKey: String, product: Product, completion: @escaping (BridgeTokenResponse?) -> Void) {
        guard let request = makeBridgeTokenRequest(accessKey: accessKey, product: product) else { return }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard
                    let data = data,
                    let tokenResponse = try? JSONDecoder().decode(BridgeTokenResponse.self, from: data)
                else { return completion(nil) }

                completion(tokenResponse)
            }
        }
        task.resume()
    }

    // MARK: - Private

    private func makeBridgeTokenRequest(accessKey: String, product: Product) -> URLRequest? {
        guard let tokenUrl = URL(string:"\(Endpoint.apiHost)/v1/bridge-tokens/") else { return nil }

        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let clientId = AppState.shared.settings.clientId.value {
            request.addValue(clientId, forHTTPHeaderField: "X-Access-Client-Id")
        }
        request.addValue(accessKey, forHTTPHeaderField: "X-Access-Secret")
        request.httpBody = BridgeTokenRequest(product: product).toJSONData()

        return request
    }

}
