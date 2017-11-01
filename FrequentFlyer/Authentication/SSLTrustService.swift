import Foundation

class SSLTrustService {
    private static let dataKey = "trustedBaseURLs"

    func hasRegisteredTrust(forBaseURL baseURL: String) -> Bool {
        if let trustedURL = UserDefaults.standard.value(forKey: SSLTrustService.dataKey) as? String {
            return baseURL == trustedURL
        }

        return false
    }

    func registerTrust(forBaseURL baseURL: String) {
        UserDefaults.standard.set(baseURL, forKey: SSLTrustService.dataKey)
    }

    func revokeTrust(forBaseURL baseURL: String) {
        clearAllTrust()
    }

    func clearAllTrust() {
        UserDefaults.standard.removeObject(forKey: SSLTrustService.dataKey)
    }
}
