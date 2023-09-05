import Foundation

public enum TruvEvent {

    case onClose
    case onError
    case onEvent(TruvEventPayload?)
    case onLoad
    case onSuccess(TruvSuccessPayload?)

    static func make(with event: TruvEventType, payload: Data?) -> Self {
        switch event {
        case .onClose:
            return .onClose
        case .onError:
            return .onError
        case .onEvent:
            let eventPayload: TruvEventPayload?
            if let payload = payload {
                eventPayload = try? JSONDecoder().decode(TruvEventPayload.self, from: payload)
            } else {
                eventPayload = nil
            }
            return .onEvent(eventPayload)
        case .onLoad:
            return .onLoad
        case .onSuccess:
            let successPayload: TruvSuccessPayload?
            if let payload = payload {
                successPayload = try? JSONDecoder().decode(TruvSuccessPayload.self, from: payload)
            } else {
                successPayload = nil
            }
            return .onSuccess(successPayload)
        }
    }
    
    var rawValue: Dictionary<String, Any> {
        get {
            switch self {
            case .onClose:
                return ["type": "onClose"]
            case .onError:
                return ["type": "onError"]
            case let .onEvent(payload):
                return ["type": "onEvent", "payload": payload?.dictionary as Any]
            case let .onSuccess(payload):
                return ["type": "onSuccess", "payload": payload?.dictionary as Any]
            case .onLoad:
                return ["type": "onLoad"]
            }
        }
    }

}
