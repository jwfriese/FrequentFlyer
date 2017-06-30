import protocol Foundation.LocalizedError

struct UnexpectedError: LocalizedError {
    var errorDescription: String? {
        get {
            return "Unexpected error encountered"
        }
    }

    var failureReason: String? {
        get {
            return "Unexpected error encountered"
        }
    }
}
