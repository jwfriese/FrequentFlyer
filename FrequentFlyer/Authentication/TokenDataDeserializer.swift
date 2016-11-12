import Foundation

class TokenDataDeserializer {
    func deserialize(_ tokenData: Data) -> (token: Token?, error: DeserializationError?) {
        var tokenDataJSONObject: Any?
        do {
            tokenDataJSONObject = try JSONSerialization.jsonObject(with: tokenData, options: .allowFragments)
        } catch { }

        guard let tokenDataDictionary = tokenDataJSONObject as? NSDictionary else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        guard tokenDataDictionary.value(forKey: "value") != nil else {
            return (nil, DeserializationError(details: "Missing required 'value' key", type: .missingRequiredData))
        }

        guard let tokenValue = tokenDataDictionary["value"] as? String else {
            return (nil, DeserializationError(details: "Expected value for 'value' key to be a string", type: .typeMismatch))
        }

        return (Token(value: tokenValue), nil)
    }
}
