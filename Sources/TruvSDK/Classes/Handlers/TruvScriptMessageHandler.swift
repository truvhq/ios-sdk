import WebKit

final class TruvScriptMessageHandler: NSObject, WKScriptMessageHandler {

    // MARK: - Properties

    weak var delegate: TruvDelegate?
    private let dataItem: TruvScriptMessageHandlerDataItem

    init(dataItem: TruvScriptMessageHandlerDataItem) {
        self.dataItem = dataItem
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if
            let body = message.body as? [String: Any],
            let payload = body["payload"] as? [String: Any],
            let eventType = payload["event_type"] as? String,
            let eventPayload = payload["payload"] as? [String: Any]
        {
            handleExternalAuthorization(body: body, eventPayload: eventPayload, eventType: eventType)
            return
        }
        
        if
            let body = message.body as? [String: Any],
            let eventName = body["event"] as? String,
            let name = TruvEventType(rawValue: eventName)
        {
            handleEvent(body: body, event: name)
            return
        }
    }
}

// MARK: - Event handlers

extension TruvScriptMessageHandler {

    private func handleEvent(
        body: [String: Any],
        event: TruvEventType
    ) {
        var payload: Data?
        if let payloadJson = body["payload"] {
            payload = try? JSONSerialization.data(withJSONObject: payloadJson, options: .prettyPrinted)
        }
        let event = TruvEvent.make(with: event, payload: payload)
        event.triggerHapticFeedback()

        delegate?.onEvent(event)
    }

    private func handleExternalAuthorization(
        body: [String: Any],
        eventPayload: [String: Any],
        eventType: String
    ) {
        if eventType == "START_EXTERNAL_LOGIN" {
            guard let data = try? JSONSerialization.data(withJSONObject: eventPayload, options: []) else {
                return
            }

            guard let loginData = try? JSONDecoder().decode(TruvProviderAuthDetails.self, from: data) else {
                return
            }

            dataItem.routeHandler(.loginRequest(loginData))
            return
        }

        if eventType == "OAUTH_OPENED" {
            guard
                let urlStr = eventPayload["url"] as? String,
                let url = URL(string: urlStr)
            else {
                return
            }

            dataItem.routeHandler(.oAuthRequest(url))
            return
        }
    }

}
