import Foundation
import RxSwift

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<AuthMethod> {
        var authMethodsJSONObject: Any?
        do {
            authMethodsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        return Observable.create { observer in
            guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
                observer.onError(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
                return Disposables.create()
            }

            for authMethodsDictionary in authMethodsJSON {
                guard let typeString = authMethodsDictionary["type"] as? String else { continue }
                guard let urlString = authMethodsDictionary["auth_url"] as? String else { continue }

                var type = AuthType.basic
                if typeString == "basic" {
                    type = .basic
                } else if typeString == "oauth" {
                    type = .github
                }

                observer.onNext(AuthMethod(type: type, url: urlString))
            }

            observer.onCompleted()

            return Disposables.create()
        }
    }
}
