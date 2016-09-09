import Foundation

class NSUserDefaultsService {
    func setData(data: NSData, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getDataForKey(key: String) -> NSData? {
        return NSUserDefaults.standardUserDefaults().dataForKey(key)
    }
}