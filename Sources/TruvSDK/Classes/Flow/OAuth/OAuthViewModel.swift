import Foundation

enum OAuthViewState {
    case loading
    case content(OAuthViewContent)
}

struct OAuthViewContent {
    let request: URL?
}

enum OAuthViewAction {
    case didAppear
    case onComplete
}

class OAuthViewModel {

    private let apiService = APIService()
    private let inputParameters: OAuthWebViewInputParameters
    @Published var state: OAuthViewState = .loading

    init(inputParameters: OAuthWebViewInputParameters) {
        self.inputParameters = inputParameters
    }

    func handle(_ action: OAuthViewAction) {
        switch action {
            case .didAppear:
                state = .content(.init(request: inputParameters.request))
            case .onComplete:
                inputParameters.onComplete()
        }
    }
}
