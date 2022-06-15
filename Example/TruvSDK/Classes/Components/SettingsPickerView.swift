import UIKit

final class SettingsPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Properties

    private let data: [String]

    var selectedValue: String {
        get {
            return data[selectedRow(inComponent: 0)]
        }
    }

    // MARK: - Lifecycle

    init(data: [String]) {
        self.data = data

        super.init(frame: .zero)

        backgroundColor = .white

        super.delegate = self
        super.dataSource = self
        reloadAllComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Delegate & Data Source methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }

}
