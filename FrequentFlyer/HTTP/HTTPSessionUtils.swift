import Foundation
import WebKit

class HTTPSessionUtils {
    func deleteCookies() {
        URLSession.shared.reset {}
        UserDefaults.standard.synchronize()

        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {})
        }
    }
}
