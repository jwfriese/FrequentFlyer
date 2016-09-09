import Foundation

class NSUserDefaultsService {
    func setData(data: NSData, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key)
    }
    
    func getDataForKey(key: String) -> NSData? {
        return NSUserDefaults.standardUserDefaults().dataForKey(key)
    }
}