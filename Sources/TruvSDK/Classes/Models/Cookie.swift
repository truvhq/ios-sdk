struct Cookie: Encodable {
    var name: String
    var value: String
    var path: String
    var domain: String
    var secure: Bool
    var httpOnly: Bool

    init(params: [String : String]) {
        self.name = params["name"] ?? ""
        self.value = params["value"] ?? ""
        self.domain = params["domain"] ?? ""
        self.path = params["path"] ?? ""
        self.secure = params["secure"]?.lowercased() == "true"
        self.httpOnly = params["httponly"]?.lowercased() == "true"
    }
}
