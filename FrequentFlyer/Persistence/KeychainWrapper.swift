import Foundation
import Locksmith

class KeychainWrapper {
    func saveTarget(target: Target) {
        do {
            let accountName = "target"
            try Locksmith.updateData(target.data,
                                     forUserAccount: accountName,
                                     inService: Target.serviceName)
        } catch {
            print("Error saving logged-in target data to the keychain")
        }
    }

    func retrieveTarget() -> Target? {
        let accountName = "target"
        guard let data = Locksmith.loadDataForUserAccount(accountName, inService: Target.serviceName)
            else { return nil }

        guard let name = data["name"] as? String else { return nil }
        guard let api = data["api"] as? String else { return nil }
        guard let teamName = data["teamName"] as? String else { return nil }
        guard let tokenValue = data["token"] as? String else { return nil }

        return Target(name: name, api: api, teamName: teamName, token: Token(value: tokenValue))
    }
}
