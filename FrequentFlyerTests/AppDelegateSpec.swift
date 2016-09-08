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
                    let application = UIApplication.sharedApplication()
                    application.delegate = subject
                    subject.application(application, didFinishLaunchingWithOptions: nil)
                }
                
                it("will have set up the main window with a navigation controller containing a TargetListViewController") {
                    guard let rootNavigationController = subject.window?.rootViewController as? UINavigationController else {
                        fail("Failed to set the application window up with a navigation controller")
                        return
                    }
                    
                    guard let targetListViewController = rootNavigationController.topViewController as? TargetListViewController else {
                        fail("Failed to set root view controller as a TargetListViewController")
                        return
                    }
                    
                    expect(targetListViewController.targetListService).toNot(beNil())
                }
            }
        }
    }
}
