import Foundation
import Locksmith

class KeychainWrapper {
    private class var accountName: String { get { return "target" } }

    func saveTarget(target: Target) {
        do {
            try Locksmith.updateData(target.data,
                                     forUserAccount: KeychainWrapper.accountName,
                                     inService: Target.serviceName)
        } catch {
            print("Error saving logged-in target data to the keychain")
        }
    }

    func retrieveTarget() -> Target? {
        guard let data = Locksmith.loadDataForUserAccount(KeychainWrapper.accountName,
                                                          inService: Target.serviceName)
            else { return nil }

        guard let name = data["name"] as? String else { return nil }
        guard let api = data["api"] as? String else { return nil }
        guard let teamName = data["teamName"] as? String else { return nil }
        guard let tokenValue = data["token"] as? String else { return nil }

        return Target(name: name, api: api, teamName: teamName, token: Token(value: tokenValue))
    }

    func deleteTarget() {
        do {
            try Locksmith.deleteDataForUserAccount(KeychainWrapper.accountName,
                                                   inService: Target.serviceName)
        } catch {
            print("Error saving logged-in target data to the keychain")
        }
    }
}
