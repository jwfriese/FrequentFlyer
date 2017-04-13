struct AuthMethod {
    let type: AuthType
    let displayName: String
    let url: String

    class DisplayNames {
        static let basic = "Basic Auth"
        static let gitHub = "GitHub"
        static let uaa = "UAA"
    }

    init(type: AuthType, displayName: String, url: String) {
        self.type = type
        self.displayName = displayName
        self.url = url
    }
}

extension AuthMethod: Equatable {}

func ==(lhs: AuthMethod, rhs: AuthMethod) -> Bool {
    return lhs.type == rhs.type &&
        lhs.displayName == rhs.displayName &&
        lhs.url == rhs.url
}
