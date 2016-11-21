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
                        Fleet.setApplicationWindowRootViewController(navigationController)
                    }

                    it("presents the ConcourseEntryViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockConcourseEntryViewController))
                    }

                    it("sets a UserTextInputPageOperator on the view controller") {
                        expect(mockConcourseEntryViewController.userTextInputPageOperator).toEventuallyNot(beNil())
                    }

                    it("sets an AuthMethodsService on the view controller") {
                        expect(mockConcourseEntryViewController.authMethodsService).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.authMethodsService?.httpClient).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.authMethodsService?.authMethodsDataDeserializer).toEventuallyNot(beNil())
                    }

                    it("sets an UnauthenticatedTokenService on the view controller") {
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService?.httpClient).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService?.tokenDataDeserializer).toEventuallyNot(beNil())
                    }
                }

                describe("When the keychain contains a saved target") {
                    beforeEach {
                        mockKeychainWrapper.toReturnTarget = try! Factory.createTarget()

                        let navigationController = UINavigationController(rootViewController: subject)
                        Fleet.setApplicationWindowRootViewController(navigationController)
                    }

                    it("replaces itself with the TeamPipelinesViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                    }

                    it("sets the retrieved target on the view controller") {
                        expect(mockTeamPipelinesViewController.target).toEventually(equal(mockKeychainWrapper.toReturnTarget))
                    }

                    it("sets a TeamPipelinesService on the view controller") {
                        expect(mockTeamPipelinesViewController.teamPipelinesService).toEventuallyNot(beNil())
                        expect(mockTeamPipelinesViewController.teamPipelinesService?.httpClient).toEventuallyNot(beNil())
                        expect(mockTeamPipelinesViewController.teamPipelinesService?.pipelineDataDeserializer).toEventuallyNot(beNil())
                    }

                    it("sets a KeychainWrapper on the view controller") {
                        expect(mockTeamPipelinesViewController.keychainWrapper).toEventuallyNot(beNil())
                    }
                }
            }
        }
    }
}
