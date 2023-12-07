import Combine
import WebKit

class LoginWebViewController: UIViewController {

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
        let webConfiguration = WKWebViewConfiguration()
        let wkcontentController = WKUserContentController()

        wkcontentController.add(self, name: "bridge")
        wkcontentController.add(self, name: "callback")

        webConfiguration.userContentController = wkcontentController

        let webView = WKWebView(
            frame: .zero,
            configuration: webConfiguration
        )
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self

        if #available(iOS 16.4, *) { webView.isInspectable = true; }

        return webView
    }()

    private var timer: Timer?
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: LoginViewModel) {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
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

    private func handleStateChange(newState: LoginViewState) {
        switch newState {
            case .loading:
                activityIndicator.startAnimating()
                webview.isHidden = true
                webViewHeaderView.isHidden = true
            case .content(let loginViewContent):
                activityIndicator.stopAnimating()
                webview.isHidden = false
                webViewHeaderView.isHidden = false
                addScriptIfNeeded(script: loginViewContent.script)
                configureWebViewHeader(loginContent: loginViewContent)
                loadURL(loginContent: loginViewContent)
        }
    }

    private func configureWebViewHeader(loginContent: LoginViewContent) {
        webViewHeaderView.setup(
            with: loginContent.request?.host ?? "",
            onRefreshAction: { [weak self] in
                self?.reload()
            }
        )
    }

    private func loadURL(loginContent: LoginViewContent) {
        if let url = loginContent.request {
            webview.load(URLRequest(url: url))
            pollSuccessfulLogin(successfulLoginSelector: loginContent.successfulLoginSelector)
        }
    }

    private func addScriptIfNeeded(script: String?) {
        if let js = script {
            let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webview.configuration.userContentController.addUserScript(script)
        }
    }

    private func pollSuccessfulLogin(successfulLoginSelector: String) {
        DispatchQueue.main.async {
            let timer = Timer.scheduledTimer(
                withTimeInterval: 0.3,
                repeats: true,
                block: { [weak self] timer in
                    guard let self else {
                        return
                    }

                    print("poll login...")

                    self.webview.evaluateJavaScript("window.document.evaluate(\"\(successfulLoginSelector)\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue != null")
                    { (result, error) in
                        if let castedResult = result as? Int, castedResult == 1 {
                            getCookies { cookies in
                                let url = self.webview.url?.absoluteString
                                self.viewModel.handle(.onLogin(url: url, cookies: cookies))

                                timer.invalidate()

                                cleanAllCookies(webView: self.webview)
                            }
                        }
                    }
                }
            )
            timer.fire()

            self.setTimer(timer: timer)
        }
    }

    // MARK: - Public functions

    func reload() {
        webview.reload()
    }

    func injectJavascript(js: String) {
        webview.evaluateJavaScript(js)
    }

    func setTimer(timer: Timer) {
        self.timer = timer
    }

    func cleanup() {
        timer?.invalidate()
    }
}

extension LoginWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.allow)
    }
}

extension LoginWebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage)  {
        if message.name == "bridge" {
            webview.evaluateJavaScript("document.querySelector()", completionHandler: nil)
        }

        if message.name == "callback" {
            print("script callback called", message.body)
            viewModel.handle(.scriptCallbackCalled(data: message.body as? String ?? "{}"))
        }
    }
}

func getCookies(completion: @escaping ([Cookie]) -> ())  {
    var cookiesList = [Cookie]()
    let cookieStore = WKWebsiteDataStore.default().httpCookieStore
    cookieStore.getAllCookies { cookies in
        for cookie in cookies {
            guard let properties = cookie.properties else { continue }

            var valuesDict = [String : String]()

            for (key, value) in properties {
                valuesDict[key.rawValue.lowercased()] = value as? String
            }

            cookiesList.append(Cookie(params: valuesDict))
        }
        completion(cookiesList)
    }
}

func cleanAllCookies(webView: WKWebView) {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

    let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

    cookieStore.getAllCookies { cookies in
        for cookie in cookies {
            cookieStore.delete(cookie)
        }
    }
}
