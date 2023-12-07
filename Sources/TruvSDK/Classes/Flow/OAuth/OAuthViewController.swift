import Combine
import WebKit

class OAuthWebViewController: UIViewController {

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private var webViewHeaderView: WebViewHeader = {
        let view = WebViewHeader(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var webview: WKWebView = {
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true

        let webConfiguration = WKWebViewConfiguration()

        webConfiguration.preferences = wkPreferences

        let webView = WKWebView(
            frame: .zero,
            configuration: webConfiguration
        )

        webView.navigationDelegate = self

        if #available(iOS 16.4, *) { webView.isInspectable = true }

        return webView
    }()

    private let viewModel: OAuthViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: OAuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.handle(.didAppear)
    }

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(webview)
        view.addSubview(webViewHeaderView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            webViewHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewHeaderView.topAnchor.constraint(equalTo: view.topAnchor),

            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.topAnchor.constraint(equalTo: webViewHeaderView.bottomAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.$state
            .sink { [weak self] state in
                self?.handleStateChange(newState: state)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(newState: OAuthViewState) {
        switch newState {
            case .loading:
                activityIndicator.startAnimating()
                webview.isHidden = true
                webViewHeaderView.isHidden = true
            case .content(let oauthViewContent):
                activityIndicator.stopAnimating()
                webview.isHidden = false
                webViewHeaderView.isHidden = false
                configureWebViewHeader(oauthViewContent: oauthViewContent)
                loadURL(oauthViewContent: oauthViewContent)
        }
    }

    private func configureWebViewHeader(oauthViewContent: OAuthViewContent) {
        webViewHeaderView.setup(
            with: oauthViewContent.request?.host ?? "",
            onRefreshAction: { [weak self] in
                self?.reload()
            }
        )
    }

    private func loadURL(oauthViewContent: OAuthViewContent) {
        if let url = oauthViewContent.request {
            webview.load(URLRequest(url: url))
        }
    }

    // MARK: - Public functions

    func reload() {
        webview.reload()
    }

    func injectJavascript(js: String) {
        webview.evaluateJavaScript(js)
    }
}

extension OAuthWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }

        if url.contains(Constants.oAuthResultURL) {
            viewModel.handle(.onComplete)
        }

        decisionHandler(.allow)
    }
}
