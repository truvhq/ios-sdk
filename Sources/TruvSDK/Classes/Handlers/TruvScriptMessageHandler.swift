import WebKit

final class TruvScriptMessageHandler: NSObject, WKScriptMessageHandler {

    // MARK: - Properties

    weak var delegate: TruvDelegate?
    
    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let eventName = body["event"] as? String,
            let name = TruvEventType(rawValue: eventName)
        else { return }

        var payload: Data?
        if let payloadJson = body["payload"] {
            payload = try? JSONSerialization.data(withJSONObject: payloadJson, options: .prettyPrinted)
        }
        let event = TruvEvent.make(with: name, payload: payload)

        delegate?.onEvent(event)
    }

}
