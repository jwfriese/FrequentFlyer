import Foundation
import RxSwift

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[AuthMethod]> {
        let authMethodsJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }
        
        let authMethods = authMethodsJSON.flatMap { authMethodsDictionary -> AuthMethod? in
            guard let typeString = authMethodsDictionary["type"] as? String else { return nil }
            guard let displayNameString = authMethodsDictionary["display_name"] as? String else { return nil }
            guard let urlString = authMethodsDictionary["auth_url"] as? String else { return nil }
            
            var type = AuthType.basic
            if typeString == "basic" && displayNameString == AuthMethod.DisplayNames.basic {
                type = .basic
            } else if typeString == "oauth" && displayNameString == AuthMethod.DisplayNames.gitHub {
                type = .gitHub
            } else if typeString == "oauth" && displayNameString == AuthMethod.DisplayNames.uaa {
                type = .uaa
            } else {
                return nil
            }
            
            return AuthMethod(type: type, displayName: displayNameString, url: urlString)
        }

        return Observable.from(optional: authMethods)
    }
}
