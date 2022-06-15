public struct TruvSuccessPayload: Codable {

    let publicToken: String
    let metadata: Metadata

    public struct Metadata: Codable {
        let taskId: String
        let employer: TruvEmployer?

        private enum CodingKeys: String, CodingKey {
            case taskId = "task_id"
            case employer
        }
    }
        
    private enum CodingKeys: String, CodingKey {
        case publicToken = "public_token"
        case metadata
    }
    
}
