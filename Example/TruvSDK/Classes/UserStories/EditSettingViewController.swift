import UIKit

final class EditSettingViewController: UIViewController {

    // MARK: - Properties

    private lazy var inputTextField = UITextField()
    private lazy var hintLabel = UILabel()

    private let setting: ProductSetting

    // MARK: - Lifecycle

    init(setting: ProductSetting) {
        self.setting = setting

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .main
        title = setting.type.title
        inputTextField.text = setting.value

        inputTextField.returnKeyType = .done
        inputTextField.delegate = self
        inputTextField.autocorrectionType = .no
        inputTextField.keyboardType = setting.type.isNumericInput ? .decimalPad : .default
        inputTextField.becomeFirstResponder()

        let tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognize)

        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        setupLayout()
        setupHintLabel()
    }

    // MARK: - Private

    private func setupLayout() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            containerView.heightAnchor.constraint(equalToConstant: 44)
        ])

        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
            inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])


        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)
        NSLayoutConstraint.activate([
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hintLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16)
        ])
    }

    private func setupHintLabel() {
        hintLabel.textColor = .textGray
        hintLabel.numberOfLines = 0
        hintLabel.font = .systemFont(ofSize: 15)

        let attributedString = NSMutableAttributedString(string: setting.type.hint)
        for param in setting.type.tappableParams {
            let rangeOfParam = (setting.type.hint as NSString).range(of: param)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.accentGreen, range: rangeOfParam)
        }

        hintLabel.attributedText = attributedString
        hintLabel.isUserInteractionEnabled = true
        hintLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(didTapHintLabel(gesture:))))
    }

    @objc private func didTapHintLabel(gesture: UITapGestureRecognizer) {
        if setting.type.tappableParams.count == 1 {
            inputTextField.text = setting.type.tappableParams.first
            textFieldDidChange()
            navigationController?.popViewController(animated: true)
            return
        }
        for param in setting.type.tappableParams {
            let rangeOfParam = (setting.type.hint as NSString).range(of: param)
            if gesture.didTapAttributedTextInLabel(label: hintLabel, inRange: rangeOfParam) {
                inputTextField.text = param
                textFieldDidChange()
                navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        if inputTextField.text?.isEmpty == true {
            setting.value = nil
        } else {
            setting.value = inputTextField.text
        }
    }

}

extension EditSettingViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationController?.popViewController(animated: true)
        return true
    }

}
