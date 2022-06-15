public struct TruvEventPayload: Codable {

    let payload: Payload?
    let eventType: EventType

    public struct Payload: Codable {
        let bridgeToken: String?
        let productType: String?
        let viewName: String?
        let employer: TruvEmployer?
        let publicToken: String?
        let taskId: String?
        let providerId: String?
        let error: TruvError?

        private enum CodingKeys: String, CodingKey {
            case bridgeToken = "bridge_token"
            case productType = "product_type"
            case viewName = "view_name"
            case employer
            case publicToken = "public_token"
            case taskId = "task_id"
            case providerId = "provider_id"
            case error
        }
    }

    private enum CodingKeys: String, CodingKey {
        case payload
        case eventType = "event_type"
    }

    enum EventType: String, Codable {
        case load = "LOAD"
        case open = "OPEN"
        case screenView = "SCREEN_VIEW"
        case employerSelected = "EMPLOYER_SELECTED"
        case linkCreated = "LINK_CREATED"
        case loginComplete = "LOGIN_COMPLETE"
        case success = "SUCCESS"
        case error = "ERROR"
        case unsupportedBrowser = "UNSUPPORTED_BROWSER"
        case close = "CLOSE"
    }

}
