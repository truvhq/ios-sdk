import UIKit

final class MenuTableViewCell: UITableViewCell {

    var activationTextField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupLayout() {
        activationTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activationTextField)
        NSLayoutConstraint.activate([
            activationTextField.topAnchor.constraint(equalTo: topAnchor),
            activationTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            activationTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            activationTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            activationTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        activationTextField.isHidden = true
    }
}
