import Foundation

class NSUserDefaultsService {
    func setData(_ data: Data, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }

    func getDataForKey(_ key: String) -> Data? {
        return UserDefaults.standard.data(forKey: key)
    }
}
