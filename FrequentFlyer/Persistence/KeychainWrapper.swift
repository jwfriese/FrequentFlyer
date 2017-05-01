import Foundation
import Locksmith

class KeychainWrapper {
    fileprivate class var accountName: String { get { return "" } }

    func saveTarget(_ target: Target) {
        do {
            let freshAccount = TargetAccount(withTarget: target)
            try freshAccount.updateInSecureStore()
        } catch let error {
            print("Error saving logged-in target data to the keychain: \(error)")
        }
    }

    func retrieveTarget() -> Target? {
        guard let data = TargetAccount.applicationAccount().readFromSecureStore()?.data
            else { return nil }

        guard let name = data["name"] as? String else { return nil }
        guard let api = data["api"] as? String else { return nil }
        guard let teamName = data["teamName"] as? String else { return nil }
        guard let tokenValue = data["token"] as? String else { return nil }

        return Target(name: name, api: api, teamName: teamName, token: Token(value: tokenValue))
    }

    func deleteTarget() {
        do {
            try TargetAccount.applicationAccount().deleteFromSecureStore()
        } catch let error {
            print("Error deleting logged-in target data from the keychain: \(error)")
        }
    }
}

fileprivate struct TargetAccount {
    let _target: Target?
    var target: Target! {
        get {
            return _target!
        }
    }

    static func applicationAccount() -> TargetAccount {
        return TargetAccount()
    }

    private init() {
        _target = nil
    }

    init(withTarget target: Target) {
        _target = target
    }
}

extension TargetAccount: CreateableSecureStorable {
    var data: [String : Any] {
        get {
            return [
                "name" : target.name as AnyObject,
                "api" : target.api as AnyObject,
                "teamName" : target.teamName as AnyObject,
                "token" : target.token.value as AnyObject
            ]
        }
    }
}

extension TargetAccount: GenericPasswordSecureStorable {
    var service: String {
        get {
            return "Authentication"
        }
    }

    var account: String {
        get {
            return "Target"
        }
    }

    var accessible: LocksmithAccessibleOption? {
        get {
            return LocksmithAccessibleOption.whenPasscodeSetThisDeviceOnly
        }
    }
}

extension TargetAccount: ReadableSecureStorable { }

extension TargetAccount: DeleteableSecureStorable { }
