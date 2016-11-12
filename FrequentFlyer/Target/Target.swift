class Target {
    fileprivate(set) var name: String
    fileprivate(set) var api: String
    fileprivate(set) var teamName: String
    fileprivate(set) var token: Token

    init(name: String,
         api: String,
         teamName: String,
         token: Token) {
        self.name = name
        self.api = api
        self.teamName = teamName
        self.token = token
    }
}

extension Target: Equatable {}

func ==(lhs: Target, rhs: Target) -> Bool {
    return lhs.name == rhs.name &&
        lhs.api == rhs.api &&
        lhs.teamName == rhs.teamName &&
        lhs.token == rhs.token
}

extension Target: KeychainPersistable {
    static var serviceName: String {
        get {
            return "Authentication"
        }
    }

    var data: [String : AnyObject] {
        get {
            return [
                "name" : name as AnyObject,
                "api" : api as AnyObject,
                "teamName" : teamName as AnyObject,
                "token" : token.value as AnyObject
            ]
        }
    }
}
