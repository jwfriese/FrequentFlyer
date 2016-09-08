struct BasicError: Error {
    private(set) var details: String
    
    init(details: String) {
        self.details = details
    }
}

extension BasicError: Equatable { }

func ==(lhs: BasicError, rhs: BasicError) -> Bool {
    return lhs.details == rhs.details
}

extension BasicError: CustomStringConvertible {
    var description: String {
        get {
            return "Error { details: \"\(details)\" }"
        }
    }
}