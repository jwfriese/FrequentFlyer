import Foundation

class AuthMethodDataDeserializer {
    func deserialize(_ data: Data) -> (authMethods: [AuthMethod]?, error: DeserializationError?) {
        var authMethodsJSONObject: Any?
        do {
            authMethodsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        var authMethods = [AuthMethod]()
        for authMethodsDictionary in authMethodsJSON {
            guard let typeString = authMethodsDictionary["type"] as? String else { continue }
            guard let urlString = authMethodsDictionary["auth_url"] as? String else { continue }

            var type = AuthType.basic
            if typeString == "basic" {
                type = .basic
            } else if typeString == "oauth" {
                type = .github
            }

            authMethods.append(AuthMethod(type: type, url: urlString))
        }

        return (authMethods, nil)
    }
}
