import Foundation

enum ProductViewModelsFactory {

    static func makeAdditionalSettingViewModels(from product: Product, isSettingsExpanded: Bool) -> [SettingsCellViewModel] {
        guard isSettingsExpanded else { return [] }
        
        var viewModels: [SettingsCellViewModel] = []

        for setting in product.settings where product.type.avaliableSettings.contains(setting.type) {
            viewModels.append(SettingsCellViewModel(title: setting.type.title, value: setting.value))
        }

        return viewModels
    }

}
