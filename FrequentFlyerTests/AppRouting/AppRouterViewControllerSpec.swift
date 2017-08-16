import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class AppRouterViewControllerSpec: QuickSpec {
    class MockKeychainWrapper: KeychainWrapper {
        var toReturnTarget: Target?

        override func retrieveTarget() -> Target? {
            return toReturnTarget
        }
    }

    override func spec() {
        describe("AppRouterViewController") {
            var subject: AppRouterViewController!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockConcourseEntryViewController: ConcourseEntryViewController!
            var mockPipelinesViewController: PipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

                mockPipelinesViewController = try! storyboard.mockIdentifier(PipelinesViewController.storyboardIdentifier, usingMockFor: PipelinesViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: AppRouterViewController.storyboardIdentifier) as! AppRouterViewController

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper
            }

            describe("After the view loads") {
                describe("When the keychain does not contain a saved target") {
                    beforeEach {
                        mockKeychainWrapper.toReturnTarget = nil

                        let navigationController = UINavigationController(rootViewController: subject)
                        Fleet.setAsAppWindowRoot(navigationController)
                    }

                    it("presents the ConcourseEntryViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockConcourseEntryViewController))
                    }
                }

                describe("When the keychain contains a saved target") {
                    beforeEach {
                        mockKeychainWrapper.toReturnTarget = try! Factory.createTarget()

                        let navigationController = UINavigationController(rootViewController: subject)
                        Fleet.setAsAppWindowRoot(navigationController)
                    }

                    it("replaces itself with the PipelinesViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockPipelinesViewController))
                    }

                    it("sets the retrieved target on the view controller") {
                        expect(mockPipelinesViewController.target).toEventually(equal(mockKeychainWrapper.toReturnTarget))
                    }
                }
            }
        }
    }
}
