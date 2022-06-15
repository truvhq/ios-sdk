import Foundation

enum Environment: CaseIterable, Codable {

    case sandbox
    case development
    case production

    var productSettingsType: ProductSettingType {
        switch self {
        case .sandbox:
            return .sandboxEnvironment
        case .development:
            return .developmentEnvironment
        case .production:
            return .productionEnvironment
        }
    }

}
