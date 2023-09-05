import Foundation

public struct TruvSuccessPayload: Codable {

    public let publicToken: String
    public let metadata: Metadata

    public struct Metadata: Codable {
        public let taskId: String
        public let employer: TruvEmployer?

        private enum CodingKeys: String, CodingKey {
            case taskId = "task_id"
            case employer
        }
    }
        
    private enum CodingKeys: String, CodingKey {
        case publicToken = "public_token"
        case metadata
    }
    
    
    var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    
}
