import protocol Foundation.LocalizedError

struct AuthorizationError: LocalizedError {
    var errorDescription: String? {
        get {
            return "Unauthorized"
        }
    }

    var failureReason: String? {
        get {
            return "Authorization credentials rejected"
        }
    }
}
