import Foundation

final class KeychainManager {

    // MARK: - Public

    func saveSettings(_ settings: Settings) {
        let encodedData = try? JSONEncoder().encode(settings)
        save(key: Constants.settingsKey, data: encodedData)
    }

    func retrieveSettings() -> Settings? {
        guard let data = load(key: Constants.settingsKey) else { return nil }
        return try? JSONDecoder().decode(Settings.self, from: data)
    }

    // MARK: - Private

    private func save(key: String, data: Data?) {
        guard let data = data else { return }

        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)

        SecItemAdd(query as CFDictionary, nil)
    }

    private func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!, // swiftlint:disable:this force_unwrapping
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr, let data = dataTypeRef as? Data? {
            return data
        } else {
            return nil
        }
    }

}

extension Data {

    init<T>(from value: T) {
        var value = value
        var data = Data()
        withUnsafePointer(to:&value, { (ptr: UnsafePointer<T>) -> Void in
            data = Data( buffer: UnsafeBufferPointer(start: ptr, count: 1))
        })
        self.init(data)
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}

private extension KeychainManager {

    enum Constants {
        static let settingsKey = "KeychainManager.settingsKey"
    }

}
