public struct TruvSDKConfig {
    public let baseURL: String
    public let platform: TruvPlatform

    public init(
        baseURL: String,
        platform: TruvPlatform = .native
    ) {
        self.baseURL = baseURL
        self.platform = platform
    }

    public static var `default`: TruvSDKConfig = .init(
        baseURL: "https://cdn.truv.com"
    )
}
