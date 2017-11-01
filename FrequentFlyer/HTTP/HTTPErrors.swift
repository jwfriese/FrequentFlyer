enum HTTPError: Error {
    case sslValidation

    var description: String {
        get {
            switch (self) {
            case .sslValidation:
                return "SSL validation failed and the connection cannot be trusted"
            }
        }
    }
}
