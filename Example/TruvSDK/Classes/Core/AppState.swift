final class AppState {

    static let shared = AppState()

    private init() {}

    var product = Product()
    var settings = KeychainManager().retrieveSettings() ?? Settings()

}
