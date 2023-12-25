import Foundation

enum LoginViewState {
    case loading
    case content(LoginViewContent)
}

struct LoginViewContent {
    let script: String?
    let request: URL?
    let successfulLoginSelector: String
}

enum LoginViewAction {
    case didAppear
    case scriptCallbackCalled(data: String)
    case onLogin(url: String?, cookies: [Cookie])
}

class LoginViewModel {

    private let apiService = APIService()
    private let inputParameters: LoginWebViewInputParameters
    @Published var state: LoginViewState = .loading

    init(inputParameters: LoginWebViewInputParameters) {
        self.inputParameters = inputParameters
    }

    func handle(_ action: LoginViewAction) {
        switch action {
            case .didAppear:
                loadScript()
            case .scriptCallbackCalled(let data):
                invokeCallback(data: data)
            case .onLogin(let url, let cookies):
                inputParameters.onLogin(LoginResult(
                    cookies: cookies,
                    dashboardURL: url ?? "",
                    tags: generateTaskTags()
                ))
        }
    }
}

extension LoginViewModel {

    private func loadScript() {
        guard let scriptURL = inputParameters.scriptUrl else {
            state = .content(.init(
                script: nil,
                request: inputParameters.request,
                successfulLoginSelector: inputParameters.successfulLoginSelector
            ))
            return
        }

        Task {
            let script = try? await apiService.downloadScript(url: scriptURL)
            state = .content(.init(
                script: script,
                request: inputParameters.request,
                successfulLoginSelector: inputParameters.successfulLoginSelector
            ))
        }
    }

    private func invokeCallback(data: String) {
        guard let url = inputParameters.callbackUrl,
              let method = inputParameters.callbackMethod,
              let headers = inputParameters.callbackHeaders
        else {
            return
        }

        Task {
            try? await apiService.invokeCallback(
                url: url,
                method: method,
                data: data,
                headers: headers
            )
        }
    }

    private func generateTaskTags() -> [String] {
        let sdkVersion = TruvBridgeView.config.platform.sdkVersion ?? Constants.currentPackageVersion
        let source = TruvBridgeView.config.platform.platformName

        return [
            "platform:ios",
            "source:\(source)",
            "sdk_version:\(sdkVersion)"
        ]
    }

}

