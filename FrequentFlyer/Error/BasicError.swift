struct BasicError: FFError {
    fileprivate(set) var details: String

    init(details: String) {
        self.details = details
    }

    var errorDescription: String? {
        get {
            return description
        }
    }
}

extension BasicError: Equatable { }

func ==(lhs: BasicError, rhs: BasicError) -> Bool {
    return lhs.details == rhs.details
}

extension BasicError: CustomStringConvertible {
    var description: String {
        get {
            return details
        }
    }
}
