public struct TruvError: Codable {

    let type: ErrorType
    let code: ErrorCode
    let message: String

    public enum ErrorType: String, Codable {
        case link = "LINK_ERROR"
    }

    public enum ErrorCode: String, Codable {
        case noData = "LINK_ERROR"
        case unavailable = "UNAVAILABLE"
        case mfaError = "MFA_ERROR"
        case loginError = "LOGIN_ERROR"
        case error = "ERROR"
    }

    private enum CodingKeys: String, CodingKey {
        case type = "error_type"
        case code = "error_code"
        case message = "error_message"
    }

}
