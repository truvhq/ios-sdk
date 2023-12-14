import UIKit
import WebKit

public final class TruvBridgeView: UIView {

    // MARK: - Properties

    private let webView: WKWebView
    private let token: String

    static var config: TruvSDKConfig = .default

    private let router = TruvBridgeViewRouter()

    // MARK: - Lifecycle

    public init(
        token: String,
        delegate: TruvDelegate? = nil,
        config: TruvSDKConfig = .default
    ) {
        self.token = token
        Self.config = config

        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)

        super.init(frame: .zero)

        let messageHandlerDataItem = TruvScriptMessageHandlerDataItem(
            routeHandler: { [weak self] route in
                self?.handleLoginRoute(route: route)
            }
        )
        let handler = TruvScriptMessageHandler(dataItem: messageHandlerDataItem)
        handler.delegate = delegate

        webView.configuration.userContentController.add(handler, name: "iosListener")
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
        guard let url = URL(string: "\(TruvBridgeView.config.baseURL)/mobile.html?bridge_token=\(token)") else {
            return
        }
        let modifiedURL = addQueryParameters(to: url)
        let request = URLRequest(url: modifiedURL)

        webView.load(request)
    }

    private func addQueryParameters(to url: URL) -> URL {
        let urlComponents = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false)
        guard let urlComponents else {
            return url
        }

        if urlComponents.queryItems == nil {
            urlComponents.queryItems = []
        }

        urlComponents.queryItems?.append(contentsOf: [
            URLQueryItem(name: "isMobileApp", value: "true"),
            URLQueryItem(name: "__TruvExternalFeatures", value: "external_app_login")
        ])

        if let modifiedURL = urlComponents.url {
            return modifiedURL
        }

        return url
    }

}

// MARK: - Login

extension TruvBridgeView {

    private func handleLoginRoute(route: LoginRoute) {
        switch route {
            case .loginRequest(let truvProviderAuthDetails):
                showLoginView(data: truvProviderAuthDetails)
            case .oAuthRequest(let url):
                showOAuthView(url: url)
        }
    }

    private func showLoginView(data: TruvProviderAuthDetails) {
        let loginWebViewInputParameters = LoginWebViewInputParameters(
            loginInfo: data,
            onLogin: { [weak self] result in
                self?.handleSuccessfulLoginData(result: result)
                self?.router.dismissLoginController()
            }
        )
        router.presentLoginWebView(inputParameters: loginWebViewInputParameters)
    }

    private func handleSuccessfulLoginData(result: LoginResult) {
        guard let data = try? JSONEncoder().encode(result) else {
            return
        }

        let str = String(decoding: data, as: UTF8.self)
        webView.evaluateJavaScript("window.bridge?.onExternalLoginSuccess(\(str))")
    }

    private func showOAuthView(url: URL) {
        let oauthWebViewInputParameters = OAuthWebViewInputParameters(
            request: url,
            onComplete: { [weak self] in
                self?.router.dismissOAuthController()
            }
        )
        router.presentOAuthWebView(inputParameters: oauthWebViewInputParameters)
    }

}

// MARK: - WKUIDelegate

extension TruvBridgeView: WKUIDelegate {

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        UIApplication.shared.open(url)
        return nil
    }

}

// MARK: - WKNavigationDelegate

extension TruvBridgeView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if !["cdn.citadelid.com", "cdn.truv.com", "citadelid-resources.s3.us-west-2.amazonaws.com", "magic-login-proxy.truv.com"].contains(url.host) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

}
