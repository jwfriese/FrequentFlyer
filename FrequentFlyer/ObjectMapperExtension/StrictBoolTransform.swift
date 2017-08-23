import ObjectMapper
import Foundation.NSData

public struct StrictBoolTransform: TransformType {
    public typealias Object = Bool
    public typealias JSON = String

    public func transformFromJSON(_ value: Any?) -> Bool? {
        if let stringValue = value as? String {
            if stringValue == "true" {
                return true
            } else if stringValue == "false" {
                return false
            }

            return nil
        }

        guard let numberValue  = value as? NSNumber
            else { return nil }
        guard type(of: numberValue) != type(of: NSNumber(integerLiteral: 1))
            else { return nil }
        guard type(of: numberValue) == type(of: NSNumber(booleanLiteral: true))
            else { return nil }

        return value as? Bool
    }

    public func transformToJSON(_ value: Bool?) -> String? {
        guard let value = value
            else { return nil }
        return value ? "true" : "false"
    }
}
