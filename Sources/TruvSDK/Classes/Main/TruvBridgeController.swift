import UIKit

public final class TruvBridgeController: UIViewController {

    private lazy var truvBridgeView: TruvBridgeView = {
        let view = TruvBridgeView(
            token: token,
            delegate: delegate,
            config: config
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let token: String
    private let config: TruvSDKConfig
    private weak var delegate: TruvDelegate?

    public init(
        token: String,
        delegate: TruvDelegate? = nil,
        config: TruvSDKConfig = .default
    ) {
        self.token = token
        self.delegate = delegate
        self.config = config
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(truvBridgeView)

        NSLayoutConstraint.activate([
            truvBridgeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            truvBridgeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            truvBridgeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            truvBridgeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
