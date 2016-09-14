struct AuthInfo {
    private(set) var username: String
    private(set) var token: Token

    init(username: String, token: Token) {
        self.username = username
        self.token = token
    }
}

extension AuthInfo: Equatable {}

func==(lhs: AuthInfo, rhs: AuthInfo) -> Bool {
    return lhs.username == rhs.username && lhs.token == rhs.token
}

extension AuthInfo: KeychainPersistable {
    static var serviceName: String { get { return "Authentication" } }
    var account: String { get { return username } }
    var data: [String : AnyObject] {
        get {
            return [
                "username" : username,
                "token" : token.value
            ]
        }
    }
}
