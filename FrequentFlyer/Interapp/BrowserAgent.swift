import UIKit

class BrowserAgent {
    func openInBrowser(_ url: URL) {
        UIApplication.shared.openURL(url)
    }
}
