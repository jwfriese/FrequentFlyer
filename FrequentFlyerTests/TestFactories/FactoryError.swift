protocol FactoryError: ErrorType, CustomStringConvertible {}

struct FactoryPropertyTypeError<T>: FactoryError {
    private var propertyName: String
    private var expectedType: T

    init(propertyName: String, expectedType: T) {
        self.propertyName = propertyName
        self.expectedType = expectedType
    }

    var description: String {
        get {
            return "Invalid type for property override with name '\(propertyName)' (expected type='\(String(expectedType))'"
        }
    }
}
