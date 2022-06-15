import UIKit
import WebKit

public final class TruvBrowserView: UIView {

    // MARK: - Properties

    private let webView: WKWebView
    private let token: String

    private static let widgetUrl = "https://cdn.citadelid.com"

    // MARK: - Lifecycle

    public init(token: String, delegate: TruvDelegate? = nil) {
        self.token = token

        let configuration = WKWebViewConfiguration()
        let handler = TruvScriptMessageHandler()
        handler.delegate = delegate
        configuration.userContentController.add(handler, name: "iosListener")
        webView = WKWebView(frame: .zero, configuration: configuration)

        super.init(frame: .zero)

        webView.uiDelegate = self
        webView.navigationDelegate = self
        setupLayout()
        startLoading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func startLoading() {
        guard let url = URL(string: "\(TruvBrowserView.widgetUrl)/mobile.html?bridge_token=\(token)") else { return }
        let request = URLRequest(url: url)

        webView.load(request)
    }

}

// MARK: - WKUIDelegate

extension TruvBrowserView: WKUIDelegate {

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        UIApplication.shared.open(url)
        return nil
    }

}

// MARK: - WKNavigationDelegate

extension TruvBrowserView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           !["cdn.citadelid.com", "cdn.truv.com", "citadelid-resources.s3.us-west-2.amazonaws.com"].contains(url.host) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

}
