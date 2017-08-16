import Foundation
import RxSwift
import ObjectMapper

class TokenDataDeserializer {
    func deserialize(_ tokenData: Data) -> Observable<Token> {
        guard let jsonString = String(data: tokenData, encoding: String.Encoding.utf8) else {
            return Observable.error(MapError(key: "", currentValue: "", reason: "Could not interpret response from token endpoint as a UTF-8 string"))
        }

        var token: Token
        do {
            try token = Token(JSONString: jsonString)
        } catch let error {
            return Observable.error(error)
        }

        return Observable.just(token)
    }
}
