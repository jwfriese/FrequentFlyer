protocol FactoryError: Error, CustomStringConvertible {}

struct FactoryPropertyTypeError<T>: FactoryError {
    fileprivate var propertyName: String
    fileprivate var expectedType: T

    init(propertyName: String, expectedType: T) {
        self.propertyName = propertyName
        self.expectedType = expectedType
    }

    var description: String {
        get {
            return "Invalid type for property override with name '\(propertyName)' (expected type='\(String(describing: expectedType))'"
        }
    }
}
