struct TruvProviderAuthDetails: Decodable, Equatable {
    let is_logged_in: ProviderAuthLoginDetails
    let url: String
    let provider_id: String
    let script: ScriptConfig?
}

struct ProviderAuthLoginDetails: Decodable, Equatable {
    let selector: String?
    let url: String?
}

struct ScriptConfig: Decodable, Equatable {
    let url: String?
    let callback_url: String?
    let callback_method: String?
    let callback_headers: [String: String]?
}
