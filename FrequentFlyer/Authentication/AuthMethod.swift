struct AuthMethod {
    private(set) var type: AuthType

    init(type: AuthType) {
        self.type = type
    }
}

extension AuthMethod: Equatable {}

func ==(lhs: AuthMethod, rhs: AuthMethod) -> Bool {
    return true
}
