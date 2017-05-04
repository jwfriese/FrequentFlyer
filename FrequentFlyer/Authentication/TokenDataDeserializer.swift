import Foundation
import RxSwift

class TokenDataDeserializer {
    func deserialize(_ tokenData: Data) -> Observable<Token> {
        let tokenDataJSONObject = try? JSONSerialization.jsonObject(with: tokenData, options: .allowFragments)

        guard let tokenDataDictionary = tokenDataJSONObject as? NSDictionary else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        guard tokenDataDictionary.value(forKey: "value") != nil else {
            return Observable.error(DeserializationError(details: "Missing required 'value' key", type: .missingRequiredData))
        }

        guard let tokenValue = tokenDataDictionary["value"] as? String else {
            return Observable.error(DeserializationError(details: "Expected value for 'value' key to be a string", type: .typeMismatch))
        }

        return Observable.just(Token(value: tokenValue))
    }
}
