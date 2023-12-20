public enum TruvPlatform {
    case native
    case reactNative(sdkVersion: String)
    case flutter(sdkVersion: String)
}

extension TruvPlatform {

    var platformName: String {
        switch self {
            case .native:
                "native"
            case .reactNative:
                "react_native"
            case .flutter:
                "flutter"
        }
    }

    var sdkVersion: String? {
        switch self {
            case .native:
                return nil
            case .reactNative(let sdkVersion):
                return sdkVersion
            case .flutter(let sdkVersion):
                return sdkVersion
        }
    }
}
