enum DeserializationErrorType {
    case missingRequiredData
    case invalidInputFormat
    case typeMismatch

    func description() -> String {
        switch(self) {
        case .missingRequiredData:
            return "MissingRequiredData"
        case .invalidInputFormat:
            return "InvalidInputFormat"
        case .typeMismatch:
            return "TypeMismatch"
        }
    }
}

struct DeserializationError: FFError {
    fileprivate(set) var details: String
    fileprivate(set) var type: DeserializationErrorType

    init(details: String, type: DeserializationErrorType) {
        self.details = details
        self.type = type
    }

    var errorDescription: String? {
        get {
            return description
        }
    }
}

extension DeserializationError: Equatable { }

func ==(lhs: DeserializationError, rhs: DeserializationError) -> Bool {
    return lhs.details == rhs.details && lhs.type == rhs.type
}

extension DeserializationError: CustomStringConvertible {
    var description: String {
        get {
            return "DeserializationError { details: \"\(details)\", type: \"\(type.description())\" }"
        }
    }
}
