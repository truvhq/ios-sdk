import Foundation

enum LoginRoute {
    case loginRequest(TruvProviderAuthDetails)
    case oAuthRequest(URL)
}

struct TruvScriptMessageHandlerDataItem {
    let routeHandler: (LoginRoute) -> ()
}
