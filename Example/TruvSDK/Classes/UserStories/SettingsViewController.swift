import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Properties

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
    private var picker: SettingsPickerView?

    private var settings: Settings {
        get {
            AppState.shared.settings
        }
    }
    private let keychainManager = KeychainManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.settingsTitle

        navigationController?.navigationBar.prefersLargeTitles = true
        setupSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didUpdateSettings()
    }

    // MARK: - Private

    private func setupSubviews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func showEnvironmentTypePicker(forRowAt index: IndexPath) {
        guard let cell = tableView.cellForRow(at: index) as? MenuTableViewCell else { return }

        picker = SettingsPickerView(data: Environment.allCases.map { $0.title } )
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let pickerAccessory = UIToolbar()
        pickerAccessory.autoresizingMask = .flexibleHeight
        pickerAccessory.isTranslucent = false

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapPickerDoneButton))
        doneButton.tintColor = .accentGreen

        pickerAccessory.items = [flexibleSpace, doneButton]

        if let selectedIndex = Environment.allCases.firstIndex(of: settings.selectedEnvironment) {
            picker?.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        cell.activationTextField.inputView = picker
        cell.activationTextField.inputAccessoryView = pickerAccessory
        cell.activationTextField.becomeFirstResponder()
    }

    @objc private func didTapPickerDoneButton() {
        if let value = picker?.selectedValue,
           let selectedEnvironment = Environment.allCases.first(where: { $0.title == value } ) {
            settings.selectedEnvironment = selectedEnvironment
        }
        didUpdateSettings()
        view.endEditing(true)
    }

    private func didUpdateSettings() {
        keychainManager.saveSettings(settings)
        tableView.reloadData()
    }

}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        if section == 0 {
            showEnvironmentTypePicker(forRowAt: indexPath)
        } else if section == 1 {
            let editSettingsController = EditSettingViewController(setting: settings.clientId)
            navigationController?.pushViewController(editSettingsController, animated: true)
        } else if section == 2 {
            let editSettingsController = EditSettingViewController(setting: settings.accessKeys[indexPath.row])
            navigationController?.pushViewController(editSettingsController, animated: true)
        }
    }
}

extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        if section == 2 {
            return settings.accessKeys.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return L10n.accessKeys
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 25
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return UIView()
        }
        return nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) as? MenuTableViewCell
        else { return MenuTableViewCell() }

        let title: String
        let detail: String?

        let section = indexPath.section
        if section == 0 {
            title = L10n.environment
            detail = settings.selectedEnvironment.title
        } else if section == 1 {
            title = settings.clientId.type.title
            detail = settings.clientId.value
        } else {
            let accessKey = settings.accessKeys[indexPath.row]
            title = accessKey.type.title
            detail = accessKey.value
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

private extension SettingsViewController {

    enum Constants {
        static let cellReuseIdentifier = "SettingsViewCellReuseIdentifier"
    }

}
