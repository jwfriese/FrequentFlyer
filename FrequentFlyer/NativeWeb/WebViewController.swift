import UIKit
import WebKit

class WebViewController: UIViewController {
    var webPageURL: URL?

    var webView: WKWebView? {
        get {
            return view as? WKWebView
        }
    }

    class var storyboardIdentifier: String { get { return "Web" } }

    override func loadView() {
        view = WKWebView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let webPageURL = webPageURL else {
            return
        }

        let request = URLRequest(url: webPageURL)
        let _ = webView?.load(request)
    }
}
