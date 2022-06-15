import Foundation

final class ProductSetting: Codable {

    let type: ProductSettingType
    var value: String?

    init(type: ProductSettingType, value: String? = nil) {
        self.type = type
        self.value = value
    }

}

public enum ProductSettingType: Codable {

    // Product

    case companyMappingId
    case providerId
    case depositValue
    case routingNumber
    case accountNumber
    case bankName
    case accountType
    case depositType

    // Settings

    case clientId

    case sandboxEnvironment
    case developmentEnvironment
    case productionEnvironment

}
