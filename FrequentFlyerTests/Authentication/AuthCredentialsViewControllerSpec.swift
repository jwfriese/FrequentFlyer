import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class AuthCredentialsViewControllerSpec: QuickSpec {
    override func spec() {
        class MockAuthServiceConsumer: AuthServiceConsumer {
            var capturedToken: Token?

            func onAuthenticationCompleted(withToken token: Token) {
                capturedToken = token
            }
        }

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

        describe("AuthCredentialsViewController") {
            var subject: AuthCredentialsViewController!
            var mockAuthServiceConsumer: MockAuthServiceConsumer!
            var mockBasicAuthTokenService: MockBasicAuthTokenService!
            var mockKeychainWrapper: MockKeychainWrapper!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(AuthCredentialsViewController.storyboardIdentifier) as? AuthCredentialsViewController

                mockAuthServiceConsumer = MockAuthServiceConsumer()
                subject.authServiceConsumer = mockAuthServiceConsumer

                mockBasicAuthTokenService = MockBasicAuthTokenService()
                subject.basicAuthTokenService = mockBasicAuthTokenService

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper

                subject.targetName = "turtle target"
                subject.concourseURLString = "concourse URL"
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
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
                            expect(mockKeychainWrapper.capturedTargetName).to(equal("turtle target"))
                        }

                        it("passes the token along to the delegate") {
                            expect(mockAuthServiceConsumer.capturedToken).to(equal(Token(value: "turtle token")))
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
