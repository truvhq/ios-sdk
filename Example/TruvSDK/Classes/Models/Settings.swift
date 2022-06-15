import Foundation

final class Settings: Codable {

    var selectedEnvironment: Environment
    let clientId: ProductSetting
    let accessKeys: [ProductSetting]

    init() {
        selectedEnvironment = .sandbox
        clientId = ProductSetting(type: .clientId)
        accessKeys = [
            ProductSetting(type: .sandboxEnvironment),
            ProductSetting(type: .developmentEnvironment),
            ProductSetting(type: .productionEnvironment)
        ]
    }

    var keyForSelectedEnvironment: String? {
        return accessKeys.first(where: { $0.type == selectedEnvironment.productSettingsType })?.value
    }

}
