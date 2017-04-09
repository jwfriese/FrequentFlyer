import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var contentView: UIView?
    var webPageURL: URL?

    private weak var cachedWebView: WKWebView?
    weak var webView: WKWebView? {
        get {
            if cachedWebView != nil { return cachedWebView }

            let webView = contentView?.subviews.filter { subview in
                return subview.isKind(of: WKWebView.self)
                }.first as? WKWebView

            cachedWebView = webView
            return cachedWebView
        }
    }
    class var storyboardIdentifier: String { get { return "Web" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let webPageURL = webPageURL else { return }
        guard let contentView = contentView else { return }

        let webView = WKWebView()
        contentView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true

        let request = URLRequest(url: webPageURL)
        let _ = webView.load(request)
    }
}
