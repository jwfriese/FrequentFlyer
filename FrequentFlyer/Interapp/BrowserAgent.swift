import UIKit

class BrowserAgent {
    func openInBrowser(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}
