enum DeserializationErrorType {
    case MissingRequiredData
    case InvalidInputFormat
    case TypeMismatch
    
    func description() -> String {
        switch(self) {
        case MissingRequiredData:
            return "MissingRequiredData"
        case .InvalidInputFormat:
            return "InvalidInputFormat"
        case .TypeMismatch:
            return "TypeMismatch"
        }
    }
}

struct DeserializationError: Error {
    private(set) var details: String
    private(set) var type: DeserializationErrorType
    
    init(details: String, type: DeserializationErrorType) {
        self.details = details
        self.type = type
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
