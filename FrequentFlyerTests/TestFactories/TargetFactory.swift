import Foundation
import SwiftCoreExtensions
@testable import FrequentFlyer

extension Factory {
    fileprivate static var defaultTargetInfo: [String : AnyObject] {
        get {
            return [
                "name" : "turtle name" as AnyObject,
                "api" : "https://turtle.com" as AnyObject,
                "teamName" : "turtle team" as AnyObject,
                "token" : "turtle token" as AnyObject
            ]
        }
    }

    static fileprivate func _createTarget(_ overrides: NSDictionary) throws -> Target {
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

    static func createTarget(_ overrides: [String : AnyObject] = [:]) throws -> Target {
        let allOverrides = try! Factory.defaultTargetInfo.merge(overrides as NSDictionary, overwriteCollisions: true)
        return try Factory._createTarget(allOverrides)
    }
}
