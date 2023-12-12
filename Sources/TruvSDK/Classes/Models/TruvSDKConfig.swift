public struct TruvSDKConfig {
    public let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public static var `default`: TruvSDKConfig = .init(
        baseURL: "https://cdn.truv.com"
    )
}
