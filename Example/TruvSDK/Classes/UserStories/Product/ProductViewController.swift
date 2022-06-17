import UIKit
import TruvSDK

final class ProductViewController: UIViewController {

    // MARK: - Properties

    weak var consoleInput: ConsoleViewInput?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .main
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        tableView.alwaysBounceVertical = false

        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()
    private lazy var openBridgeButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .accentGreen
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitle(L10n.openBridgeButtonTitle, for: [])
        button.addTarget(self, action: #selector(didTapOpenBridgeButton), for: .touchUpInside)

        return button
    }()
    private var isSettingsExpanded = false
    private var picker: SettingsPickerView?
    private var browserView: TruvBridgeView?

    private var product: Product {
        get {
            AppState.shared.product
        }
    }
    private var additionalSettingViewModels: [SettingsCellViewModel] = []

    private let service = NetworkService()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.productTitle

        navigationController?.navigationBar.prefersLargeTitles = true
        setupSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reload()
    }

    // MARK: - Private

    private func setupSubviews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        view.addSubview(openBridgeButton)
        NSLayoutConstraint.activate([
            openBridgeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            openBridgeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            openBridgeButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            openBridgeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            openBridgeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTapExpandButton() {
        isSettingsExpanded = !isSettingsExpanded
        reload()
    }

    private func showProductTypePicker(forRowAt index: IndexPath) {
        guard let cell = tableView.cellForRow(at: index) as? MenuTableViewCell else { return }

        picker = SettingsPickerView(data: ProductType.allCases.map { $0.title } )
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let pickerAccessory = UIToolbar()
        pickerAccessory.autoresizingMask = .flexibleHeight
        pickerAccessory.isTranslucent = false

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapPickerDoneButton))
        doneButton.tintColor = .accentGreen

        pickerAccessory.items = [flexibleSpace, doneButton]

        if let selectedIndex = ProductType.allCases.firstIndex(of: product.type) {
            picker?.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        cell.activationTextField.inputView = picker
        cell.activationTextField.inputAccessoryView = pickerAccessory
        cell.activationTextField.becomeFirstResponder()
    }

    @objc private func didTapPickerDoneButton() {
        if let value = picker?.selectedValue,
           let type = ProductType.allCases.first(where: { $0.title == value } ) {
            product.type = type
        }
        reload()
        view.endEditing(true)
    }

    @objc private func didTapOpenBridgeButton() {
        guard let accessKey = AppState.shared.settings.keyForSelectedEnvironment, !accessKey.isEmpty else {
            showEmptyKeyAlert()
            return
        }

        openBridgeButton.isEnabled = false
        service.getBridgeToken(accessKey: accessKey, product: product) { [weak self] tokenResponse in
            guard let self = self else { return }
            self.openBridgeButton.isEnabled = true
            guard let token = tokenResponse?.bridge_token else {
                self.showEmptyKeyAlert()
                return
            }

            self.showWebView(token: token)
        }
    }

    private func showEmptyKeyAlert() {
        let alertController = UIAlertController(title: L10n.errorKeyAlertTitle, message: L10n.errorKeyAlertDesription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.errorKeyAlertButtonTitle, style: .default) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        })

        present(alertController, animated: true, completion: nil)
    }

    private func showWebView(token: String) {
        let browserView = TruvBridgeView(token: token, delegate: self)
        self.browserView = browserView
        browserView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(browserView)
        NSLayoutConstraint.activate([
            browserView.topAnchor.constraint(equalTo: view.topAnchor),
            browserView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            browserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func reload() {
        additionalSettingViewModels = ProductViewModelsFactory.makeAdditionalSettingViewModels(from: product, isSettingsExpanded: isSettingsExpanded)
        tableView.reloadData()
    }

    private func closeWidget() {
        browserView?.removeFromSuperview()
    }

}

extension ProductViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            showProductTypePicker(forRowAt: indexPath)
        } else {
            let editSettingsController = EditSettingViewController(setting: product.settings[indexPath.row])
            navigationController?.pushViewController(editSettingsController, animated: true)
        }
    }

}

extension ProductViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return additionalSettingViewModels.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        let button = UIButton(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 20))

        let title = isSettingsExpanded ? L10n.hideAdditionalSettings : L10n.showAdditionalSettings
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitle(title, for: [])
        button.setTitleColor(.accentGreen, for: [])
        button.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)

        view.addSubview(button)
        return view
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) as? MenuTableViewCell
        else { return MenuTableViewCell() }

        let title: String
        let detail: String?
        if indexPath.section == 0 {
            title = "Product type"
            detail = product.type.title
        } else {
            title = additionalSettingViewModels[indexPath.row].title
            detail = additionalSettingViewModels[indexPath.row].value
        }
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail

        if detail == nil {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

}

// MARK: - TruvDelegate

extension ProductViewController: TruvDelegate {

    func onEvent(_ event: TruvEvent) {
        switch event {
        case .onClose:
            consoleInput?.addLogs(name: "widget closed", message: nil)
            closeWidget()
        case .onError:
            consoleInput?.addLogs(name: "widget error", message: nil)
            closeWidget()
        case .onEvent(let payload):
            consoleInput?.addLogs(name: "widget event", message: payload.toJSONString())
        case .onLoad:
            consoleInput?.addLogs(name: "widget opened", message: nil)
        case .onSuccess(let payload):
            consoleInput?.addLogs(name: "widget succeeded", message: payload.toJSONString())
            closeWidget()
        }
    }

}

// MARK: - Nested types

private extension ProductViewController {

    enum Constants {
        static let cellReuseIdentifier = "ProductViewCellReuseIdentifier"
    }

}
