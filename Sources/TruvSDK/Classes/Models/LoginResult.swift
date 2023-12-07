struct LoginResult : Encodable {
    let cookies: [Cookie]
    let dashboardURL: String
    let tags: [String]
}
