import UIKit
import SafariServices

class TruvBridgeViewRouter {

    func presentLoginWebView(inputParameters: LoginWebViewInputParameters) {
        if let topMostController = UIApplication.topViewController() {

            let controller = LoginScene.buildScene(inputParameters: inputParameters)
            topMostController.present(controller, animated: true)
        }
    }

    func dismissLoginController() {
        if let loginController = UIApplication.topViewController() as? LoginWebViewController {
            loginController.dismiss(animated: true)
        }
    }

    func presentOAuthWebView(inputParameters: OAuthWebViewInputParameters) {
        if let topMostController = UIApplication.topViewController() {

            let controller = OAuthScene.buildScene(inputParameters: inputParameters)
            topMostController.present(controller, animated: true)
        }
    }

    func dismissOAuthController() {
        if let oauthController = UIApplication.topViewController() as? OAuthWebViewController {
            oauthController.dismiss(animated: true)
        }
    }

    func showSafariViewController(with url: URL) {
        if let topMostController = UIApplication.topViewController() {
            let safariVC = SFSafariViewController(url: url)
            topMostController.present(safariVC, animated: true)
        } else {
            UIApplication.shared.open(url)
        }
    }
}
