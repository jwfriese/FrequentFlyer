import Foundation
import RxSwift

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> Observable<AuthMethod> {
        var authMethodsJSONObject: Any?
        do {
            authMethodsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        let subject = ReplaySubject<AuthMethod>.createUnbounded()

        guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
            subject.onError(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
            return subject
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

            subject.onNext(AuthMethod(type: type, url: urlString))
        }

        subject.onCompleted()

        return subject
    }
}
