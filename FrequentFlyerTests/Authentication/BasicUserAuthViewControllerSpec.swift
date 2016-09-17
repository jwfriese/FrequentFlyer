import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class BasicUserAuthViewControllerSpec: QuickSpec {
    class MockBasicAuthTokenService: BasicAuthTokenService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var capturedUsername: String?
        var capturedPassword: String?
        var capturedCompletion: ((Token?, Error?) -> ())?

        override func getToken(forTeamWithName teamName: String, concourseURL: String, username: String, password: String, completion: ((Token?, Error?) -> ())?) {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedUsername = username
            capturedPassword = password
            capturedCompletion = completion
        }
    }

    class MockKeychainWrapper: KeychainWrapper {
        var capturedAuthInfo: AuthInfo?
        var capturedTargetName: String?

        override func saveAuthInfo(authInfo: AuthInfo, forTargetWithName targetName: String) {
            capturedAuthInfo = authInfo
            capturedTargetName = targetName
        }
    }

    class MockTeamPipelinesViewController: TeamPipelinesViewController {
        override func viewDidLoad() { }
    }

    override func spec() {
        describe("BasicUserAuthViewController") {
            var subject: BasicUserAuthViewController!
            var mockBasicAuthTokenService: MockBasicAuthTokenService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockTeamPipelinesViewController: MockTeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamPipelinesViewController = MockTeamPipelinesViewController()
                try! storyboard.bindViewController(mockTeamPipelinesViewController, toIdentifier: TeamPipelinesViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(BasicUserAuthViewController.storyboardIdentifier) as! BasicUserAuthViewController

                mockBasicAuthTokenService = MockBasicAuthTokenService()
                subject.basicAuthTokenService = mockBasicAuthTokenService

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper

                subject.concourseURLString = "concourse URL"
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }

                it("sets its title") {
                    expect(subject.title).to(equal("Login"))
                }

                describe("Availability of the 'Submit' button") {
                    it("is disabled just after the view is loaded") {
                        expect(subject.submitButton!.enabled).to(beFalse())
                    }

                    describe("When only the 'Username' field has text") {
                        beforeEach {
                            try! subject.usernameTextField?.enterText("turtle target")
                        }

                        it("leaves the button disabled") {
                            expect(subject.submitButton!.enabled).to(beFalse())
                        }
                    }

                    describe("When only the 'Password' field has text") {
                        beforeEach {
                            try! subject.passwordTextField?.enterText("Concourse turtle")
                        }

                        it("leaves the button disabled") {
                            expect(subject.submitButton!.enabled).to(beFalse())
                        }
                    }

                    describe("When both the 'Username' field and the 'Password' field have text") {
                        beforeEach {
                            try! subject.usernameTextField?.enterText("turtle target")
                            try! subject.passwordTextField?.enterText("Concourse turtle")
                        }

                        it("enables the button") {
                            expect(subject.submitButton!.enabled).to(beTrue())
                        }

                        describe("When the 'Username' field is cleared") {
                            beforeEach {
                                subject.usernameTextField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.enabled).to(beFalse())
                            }
                        }

                        describe("When the 'Password' field is cleared") {
                            beforeEach {
                                subject.passwordTextField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.enabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Entering auth credentials and submitting") {
                    beforeEach {
                        try! subject.usernameTextField?.enterText("turtle username")
                        try! subject.passwordTextField?.enterText("turtle password")
                        subject.submitButton?.tap()
                    }

                    it("calls out to the BasicAuthTokenService with the entered username and password") {
                        expect(mockBasicAuthTokenService.capturedTeamName).to(equal("main"))
                        expect(mockBasicAuthTokenService.capturedConcourseURL).to(equal("concourse URL"))
                        expect(mockBasicAuthTokenService.capturedUsername).to(equal("turtle username"))
                        expect(mockBasicAuthTokenService.capturedPassword).to(equal("turtle password"))
                    }

                    describe("When the BasicAuthTokenService resolves with a token") {
                        beforeEach {
                            guard let completion = mockBasicAuthTokenService.capturedCompletion else {
                                fail("Failed to call BasicAuthTokenService with a completion handler")
                                return
                            }

                            let token = Token(value: "turtle token")
                            completion(token, nil)
                        }

                        it("asks the KeychainWrapper to save the authentication info for this target") {
                            expect(mockKeychainWrapper.capturedAuthInfo).to(equal(AuthInfo(username: "turtle username", token: Token(value: "turtle token"))))
                            expect(mockKeychainWrapper.capturedTargetName).to(equal("target"))
                        }

                        it("replaces itself with the TeamPipelinesViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                        }

                        it("creates a new target from the entered information and view controller") {
                            let expectedTarget = Target(name: "target", api: "concourse URL",
                                                        teamName: "main", token: Token(value: "turtle token")
                            )
                            expect(mockTeamPipelinesViewController.target).toEventually(equal(expectedTarget))
                        }

                        it("sets a TeamPipelinesService on the view controller") {
                            expect(mockTeamPipelinesViewController.teamPipelinesService).toEventuallyNot(beNil())
                            expect(mockTeamPipelinesViewController.teamPipelinesService?.httpClient).toEventuallyNot(beNil())
                            expect(mockTeamPipelinesViewController.teamPipelinesService?.pipelineDataDeserializer).toEventuallyNot(beNil())
                        }
                    }

                    describe("When the BasicAuthTokenService resolves with an error") {
                        beforeEach {
                            guard let completion = mockBasicAuthTokenService.capturedCompletion else {
                                fail("Failed to call BasicAuthTokenService with a completion handler")
                                return
                            }

                            completion(nil, BasicError(details: "turtle authentication error"))
                        }

                        it("displays an alert containing the error that came from the HTTP call") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                            let screen = Fleet.getApplicationScreen()
                            expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                            let alert = screen?.topmostViewController as? UIAlertController
                            expect(alert?.title).toEventually(equal("Authorization Failed"))
                            expect(alert?.message).toEventually(equal("turtle authentication error"))
                        }
                    }
                }
            }
        }
    }
}
