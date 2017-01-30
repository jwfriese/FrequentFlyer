import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class WebViewControllerSpec: QuickSpec {
    override func spec() {
        describe("WebViewController") {
            var subject: WebViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                subject = storyboard.instantiateViewController(withIdentifier: WebViewController.storyboardIdentifier) as? WebViewController
            }

            describe("After the view loads") {
                beforeEach {
                    let bundle = Bundle(for: type(of: self))
                    let testHTMLFilePath = bundle.path(forResource: "web_view_controller_test", ofType: "html")
                    let testURL = URL(fileURLWithPath: testHTMLFilePath!)

                    subject.webPageURL = testURL

                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                it("loads its web view with its URL") {
                    let checkContentExists = "if (document.body.textContent.indexOf(\"Welcome to turtle.com\") == -1) { throw new Error(); } "

                    var didPageLoad = false
                    let predicate: () -> Bool = {
                        subject.webView?.evaluateJavaScript(checkContentExists) { (object, error) in
                            if error == nil {
                                didPageLoad = true
                            }
                        }

                        return didPageLoad
                    }

                    expect(predicate()).toEventually(beTrue(), timeout: 5)
                }
            }
        }
    }
}
