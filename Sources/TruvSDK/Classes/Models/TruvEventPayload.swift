import Foundation

public struct TruvEventPayload: Codable {

    public let payload: Payload?
    public let eventType: EventType

    public struct Payload: Codable {
        public let bridgeToken: String?
        public let productType: String?
        public let viewName: String?
        public let employer: TruvEmployer?
        public let publicToken: String?
        public let taskId: String?
        public let providerId: String?
        public let error: TruvError?

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

    public enum EventType: String, Codable {
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
    
    var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

}
