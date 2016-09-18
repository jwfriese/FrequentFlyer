import Foundation

class AuthMethodDataDeserializer {
    func deserialize(data: NSData) -> (authMethods: [AuthMethod]?, error: DeserializationError?) {
        var authMethodsJSONObject: AnyObject?
        do {
            authMethodsJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch { }

        guard let authMethodsJSON = authMethodsJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat))
        }

        var authMethods = [AuthMethod]()
        for authMethodsDictionary in authMethodsJSON {
            guard let typeString = authMethodsDictionary["type"] as? String else { continue }

            var type = AuthType.Basic
            if typeString == "basic" {
                type = .Basic
            } else if typeString == "oauth" {
                type = .Github
            }

            authMethods.append(AuthMethod(type: type))
        }

        return (authMethods, nil)
    }
}
