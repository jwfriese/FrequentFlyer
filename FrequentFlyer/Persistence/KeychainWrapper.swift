import Foundation
import Locksmith

class KeychainWrapper {
    fileprivate class var accountName: String { get { return "target" } }

    func saveTarget(_ target: Target) {
        do {
            try Locksmith.updateData(data: target.data,
                                     forUserAccount: KeychainWrapper.accountName,
                                     inService: Target.serviceName)
        } catch {
            print("Error saving logged-in target data to the keychain")
        }
    }

    func retrieveTarget() -> Target? {
        guard let data = Locksmith.loadDataForUserAccount(userAccount: KeychainWrapper.accountName,
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
            try Locksmith.deleteDataForUserAccount(userAccount: KeychainWrapper.accountName,
                                                   inService: Target.serviceName)
        } catch let error {
            print("Error deleting logged-in target data from the keychain: \(error)")
        }
    }
}
