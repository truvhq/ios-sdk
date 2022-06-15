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

}
