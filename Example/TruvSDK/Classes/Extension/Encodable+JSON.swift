import Foundation

extension Encodable {
    func toJSONData() -> Data? {
        try? JSONEncoder().encode(self)
    }

    func toJSONString() -> String? {
        guard let data = self.toJSONData() else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
}
