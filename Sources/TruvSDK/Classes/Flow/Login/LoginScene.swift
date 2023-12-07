import UIKit

struct LoginWebViewInputParameters {
    let request: URL?
    let successfulLoginSelector: String
    let scriptUrl: String?
    let callbackUrl: String?
    let callbackMethod: String?
    let callbackHeaders: [String: String]?
    let onLogin: (_ result: LoginResult) -> ()

    init(
        loginInfo: TruvProviderAuthDetails,
        onLogin: @escaping (_ result: LoginResult) -> ()
    ) {
        self.request = URL(string: loginInfo.url)
        self.successfulLoginSelector = loginInfo.is_logged_in.selector ?? ""

        self.scriptUrl = loginInfo.script?.url
        self.callbackHeaders = loginInfo.script?.callback_headers
        self.callbackUrl = loginInfo.script?.callback_url
        self.callbackMethod = loginInfo.script?.callback_method
        self.onLogin = onLogin
    }
}

class LoginScene {

    static func buildScene(inputParameters: LoginWebViewInputParameters) -> UIViewController {
        let viewModel = LoginViewModel(inputParameters: inputParameters)
        let controller = LoginWebViewController(viewModel: viewModel)
        return controller
    }
}
