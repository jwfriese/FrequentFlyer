import Foundation
import RxSwift

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<AuthMethod> {
        var authMethodsJSONObject: Any?
        do {
            authMethodsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        var authMethods = [AuthMethod]()

        guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        for authMethodsDictionary in authMethodsJSON {
            guard let typeString = authMethodsDictionary["type"] as? String else { continue }
            guard let urlString = authMethodsDictionary["auth_url"] as? String else { continue }

            var type = AuthType.basic
            if typeString == "basic" {
                type = .basic
            } else if typeString == "oauth" {
                type = .gitHub
            }

            authMethods.append(AuthMethod(type: type, url: urlString))
        }

        return Observable.from(authMethods)
    }
}
