import Foundation
import RxSwift
import ObjectMapper

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[AuthMethod]> {
        let authMethodsJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let authMethodsCollectionJSON = authMethodsJSONObject as? [[String : Any]] else {
            return Observable.error(MapError(key: "", currentValue: "", reason: "Could not interpret response from auth methods endpoint as JSON"))
        }

        let authMethods = authMethodsCollectionJSON.flatMap { authMethodJSON -> AuthMethod? in
            do {
                let authMethod: AuthMethod = try AuthMethod(JSON: authMethodJSON)
                return authMethod
            } catch {
                return nil
            }
        }

        return Observable.from(optional: authMethods)
    }
}
