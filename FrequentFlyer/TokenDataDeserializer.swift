import Foundation

class TokenDataDeserializer {
    func deserialize(tokenData: NSData) -> (token: Token?, error: DeserializationError?) {
        var tokenDataJSONObject: AnyObject?
        do {
            tokenDataJSONObject = try NSJSONSerialization.JSONObjectWithData(tokenData, options: .AllowFragments)
        } catch { }

        guard let tokenDataDictionary = tokenDataJSONObject else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat))
        }

        guard tokenDataDictionary.valueForKey("value") != nil else {
            return (nil, DeserializationError(details: "Missing required 'value' key", type: .MissingRequiredData))
        }

        guard let tokenValue = tokenDataDictionary["value"] as? String else {
            return (nil, DeserializationError(details: "Expected value for 'value' key to be a string", type: .TypeMismatch))
        }

        return (Token(value: tokenValue), nil)
    }
}
