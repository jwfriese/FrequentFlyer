import Foundation
import RxSwift

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[AuthMethod]> {
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
            guard let displayNameString = authMethodsDictionary["display_name"] as? String else { continue }
            guard let urlString = authMethodsDictionary["auth_url"] as? String else { continue }

            var type = AuthType.basic
            if typeString == "basic" && displayNameString == AuthMethod.DisplayNames.basic {
                type = .basic
            } else if typeString == "oauth" && displayNameString == AuthMethod.DisplayNames.gitHub {
                type = .gitHub
            } else {
                continue
            }

            authMethods.append(AuthMethod(type: type, displayName: displayNameString, url: urlString))
        }

        return Observable.from(optional: authMethods)
    }
}
