class Token {
    let value: String

    var authValue: String {
        get {
            if value.hasPrefix("Bearer ") {
                return value
            }

            return "Bearer \(value)"
        }
    }

    init(value: String) {
        self.value = value
    }
}

extension Token: Equatable { }

func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.value == rhs.value
}
