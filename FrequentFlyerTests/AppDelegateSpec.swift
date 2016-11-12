import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("AppDelegate") {
            var subject: AppDelegate!

            describe("After launching") {
                beforeEach {
                    subject = AppDelegate()
                    let application = UIApplication.shared
                    application.delegate = subject
                    let _ = subject.application(application, didFinishLaunchingWithOptions: nil)
                }

                it("sets up the main window with a navigation controller containing a AppRouterViewController and sets up the AppRouterViewController with its dependencies") {
                    guard let rootNavigationController = subject.window?.rootViewController as? UINavigationController else {
                        fail("Failed to set the application window up with a navigation controller")
                        return
                    }

                    guard let appRouterViewController = rootNavigationController.topViewController as? AppRouterViewController else {
                        fail("Failed to set root view controller as a AppRouterViewController")
                        return
                    }

                    expect(appRouterViewController.keychainWrapper).toNot(beNil())
                }
            }
        }
    }
}
