import UIKit

struct OAuthWebViewInputParameters {
    let request: URL
    let onComplete: () -> Void
}

class OAuthScene {

    static func buildScene(inputParameters: OAuthWebViewInputParameters) -> UIViewController {
        let viewModel = OAuthViewModel(inputParameters: inputParameters)
        let controller = OAuthWebViewController(viewModel: viewModel)
        return controller
    }
}

