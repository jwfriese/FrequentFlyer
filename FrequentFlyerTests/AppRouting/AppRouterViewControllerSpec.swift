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
            var mockTeamPipelinesViewController: TeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

                mockTeamPipelinesViewController = try! storyboard.mockIdentifier(TeamPipelinesViewController.storyboardIdentifier, usingMockFor: TeamPipelinesViewController.self)

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

                    it("replaces itself with the TeamPipelinesViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                    }

                    it("sets the retrieved target on the view controller") {
                        expect(mockTeamPipelinesViewController.target).toEventually(equal(mockKeychainWrapper.toReturnTarget))
                    }
                }
            }
        }
    }
}
