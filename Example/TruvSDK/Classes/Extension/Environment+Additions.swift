import Foundation

extension Environment {

    var title: String {
        switch self {
        case .sandbox:
            return L10n.sandbox
        case .development:
            return L10n.development
        case .production:
            return L10n.production
        }
    }

}
