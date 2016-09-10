class Token {
    private(set) var value: String

    init(value: String) {
        self.value = value
    }
}

extension Token: Equatable { }

func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.value == rhs.value
}
