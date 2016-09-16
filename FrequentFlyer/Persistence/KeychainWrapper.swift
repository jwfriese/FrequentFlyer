import Foundation
import Locksmith

class KeychainWrapper {
    func saveAuthInfo(authInfo: AuthInfo, forTargetWithName targetName: String) {
        do {
            let accountName = "\(authInfo.username):\(targetName)"
            try Locksmith.updateData(authInfo.data,
                                     forUserAccount: accountName,
                                     inService: AuthInfo.serviceName)
        } catch {
            print("Error saving data to the keychain for user '\(authInfo.account)' and target '\(targetName)'")
        }
    }

    func retrieveAuthInfo(forUserWithName username: String, andTargetWithName targetName: String) -> AuthInfo? {
        let accountName = "\(username):\(targetName)"
        guard let data = Locksmith.loadDataForUserAccount(accountName, inService: AuthInfo.serviceName)
            else { return nil }

        guard let username = data["username"] as? String else { return nil }
        guard let tokenValue = data["token"] as? String else { return nil }

        return AuthInfo(username: username, token: Token(value: tokenValue))
    }
}
