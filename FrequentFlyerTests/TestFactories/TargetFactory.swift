import Foundation
@testable import FrequentFlyer

extension Factory {
    private static var defaultTargetInfo: [String : AnyObject] {
        get {
            return [
                "name" : "turtle name",
                "api" : "https://turtle.com",
                "teamName" : "turtle team",
                "token" : "turtle token"
            ]
        }
    }

    static private func _createTarget(overrides: NSDictionary) throws -> Target {
        guard let name = overrides["name"] as? String else {
            throw FactoryPropertyTypeError(propertyName: "name", expectedType: String.self)
        }

        guard let api = overrides["api"] as? String else {
            throw FactoryPropertyTypeError(propertyName: "api", expectedType: String.self)
        }

        guard let teamName = overrides["teamName"] as? String else {
            throw FactoryPropertyTypeError(propertyName: "teamName", expectedType: String.self)
        }

        guard let tokenValue = overrides["token"] as? String else {
            throw FactoryPropertyTypeError(propertyName: "token", expectedType: String.self)
        }

        return Target(name: name,
                      api: api,
                      teamName: teamName,
                      token: Token(value: tokenValue)
        )
    }

    static func createTarget(overrides: [String : AnyObject] = [:]) throws -> Target {
        let allOverrides = try! Factory.defaultTargetInfo.merge(overrides, overwriteCollisions: true)
        return try Factory._createTarget(allOverrides)
    }
}
