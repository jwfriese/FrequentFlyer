import ObjectMapper

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

extension AuthMethod: ImmutableMappable {
    init(map: Map) throws {
        let typeString: String = try map.value("type")
        let displayNameString: String = try map.value("display_name")
        var type = AuthType.basic
        if typeString == "basic" && displayNameString == AuthMethod.DisplayNames.basic {
            type = .basic
        } else if typeString == "oauth" && displayNameString == AuthMethod.DisplayNames.gitHub {
            type = .gitHub
        } else if typeString == "oauth" && displayNameString == AuthMethod.DisplayNames.uaa {
            type = .uaa
        } else {
            throw MapError(key: "type", currentValue: "", reason: "Failed to map `AuthMethod` with `type` == `\(typeString)` and `display_name` == \(displayNameString)")
        }

        self.type = type
        self.displayName = displayNameString
        self.url = try map.value("auth_url")
    }
}
