import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class LoginViewControllerSpec: QuickSpec {
    class MockBasicAuthTokenService: BasicAuthTokenService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var capturedUsername: String?
        var capturedPassword: String?
        var capturedCompletion: ((Token?, FFError?) -> ())?

        override func getToken(forTeamWithName teamName: String, concourseURL: String, username: String, password: String, completion: ((Token?, FFError?) -> ())?) {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedUsername = username
            capturedPassword = password
            capturedCompletion = completion
        }
    }

    class MockKeychainWrapper: KeychainWrapper {
        var capturedTarget: Target?

        override func saveTarget(_ target: Target) {
            capturedTarget = target
        }
    }

    override func spec() {
        fdescribe("LoginViewController") {
            var subject: LoginViewController!
            var mockBasicAuthTokenService: MockBasicAuthTokenService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockTeamPipelinesViewController: TeamPipelinesViewController!
            var mockGithubAuthViewController: GithubAuthViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamPipelinesViewController = try! storyboard.mockIdentifier(TeamPipelinesViewController.storyboardIdentifier, usingMockFor: TeamPipelinesViewController.self)

                mockGithubAuthViewController = try! storyboard.mockIdentifier(GithubAuthViewController.storyboardIdentifier, usingMockFor: GithubAuthViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: LoginViewController.storyboardIdentifier) as! LoginViewController

                mockBasicAuthTokenService = MockBasicAuthTokenService()
                subject.basicAuthTokenService = mockBasicAuthTokenService

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper

                subject.concourseURLString = "concourse URL"
            }

            describe("After the view loads") {
                describe("Form setup") {
                    context("When only basic auth is available") {
                        beforeEach {
                            subject.authMethods = [AuthMethod(type: .basic, url: "basic-auth.com")]
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("displays the username and password entry fields") {
                            expect(subject.usernameField?.isHidden).to(beFalse())
                            expect(subject.passwordField?.isHidden).to(beFalse())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beFalse())
                        }

                        it("hides the Github auth section") {
                            expect(subject.githubAuthDisplayLabel?.isHidden).to(beTrue())
                            expect(subject.githubAuthButton?.isHidden).to(beTrue())
                        }
                    }

                    context("When only Github auth is available") {
                        beforeEach {
                            subject.authMethods = [AuthMethod(type: .github, url: "github-auth.com")]
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("hides the username and password entry fields") {
                            expect(subject.usernameField?.isHidden).to(beTrue())
                            expect(subject.passwordField?.isHidden).to(beTrue())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beTrue())
                        }

                        it("displays the Github auth section") {
                            expect(subject.githubAuthDisplayLabel?.isHidden).to(beFalse())
                            expect(subject.githubAuthButton?.isHidden).to(beFalse())
                        }
                    }

                    context("When both basic auth and Github auth are available") {
                        beforeEach {
                            subject.authMethods = [
                                AuthMethod(type: .basic, url: "basic-auth.com"),
                                AuthMethod(type: .github, url: "github-auth.com")
                            ]

                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("displays the username and password entry fields") {
                            expect(subject.usernameField?.isHidden).to(beFalse())
                            expect(subject.passwordField?.isHidden).to(beFalse())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beFalse())
                        }

                        it("displays the Github auth section") {
                            expect(subject.githubAuthDisplayLabel?.isHidden).to(beFalse())
                            expect(subject.githubAuthButton?.isHidden).to(beFalse())
                        }
                    }
                }

                describe("Submitting using basic auth") {
                    beforeEach {
                        subject.authMethods = [AuthMethod(type: .basic, url: "basic-auth.com")]
                        let _ = Fleet.setInAppWindowRootNavigation(subject)

                        try? subject.usernameField?.textField?.enter(text: "turtle username")
                        try? subject.passwordField?.textField?.enter(text: "turtle password")
                        try! subject.basicAuthLoginButton?.tap()
                    }

                    it("calls out to the BasicAuthTokenService with the entered username and password") {
                        expect(mockBasicAuthTokenService.capturedTeamName).to(equal("main"))
                        expect(mockBasicAuthTokenService.capturedConcourseURL).to(equal("concourse URL"))
                        expect(mockBasicAuthTokenService.capturedUsername).to(equal("turtle username"))
                        expect(mockBasicAuthTokenService.capturedPassword).to(equal("turtle password"))
                    }

                    it("disables the 'Submit' button") {
                        expect(subject.basicAuthLoginButton!.isEnabled).to(beFalse())
                    }

                    describe("When the BasicAuthTokenService resolves with a token") {
                        describe("When the 'Stay Logged In' switch is off") {
                            beforeEach {
                                subject.stayLoggedInSwitch?.isOn = false

                                guard let completion = mockBasicAuthTokenService.capturedCompletion else {
                                    fail("Failed to call BasicAuthTokenService with a completion handler")
                                    return
                                }

                                let token = Token(value: "turtle token")
                                completion(token, nil)
                            }

                            it("does not save anything to the keychain") {
                                expect(mockKeychainWrapper.capturedTarget).to(beNil())
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

                            it("sets a KeychainWrapper on the view controller") {
                                expect(mockTeamPipelinesViewController.keychainWrapper).toEventuallyNot(beNil())
                            }
                        }

                        describe("When the 'Stay Logged In' switch is on") {
                            beforeEach {
                                subject.stayLoggedInSwitch?.isOn = true

                                guard let completion = mockBasicAuthTokenService.capturedCompletion else {
                                    fail("Failed to call BasicAuthTokenService with a completion handler")
                                    return
                                }

                                let token = Token(value: "turtle token")
                                completion(token, nil)
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

                            it("asks the KeychainWrapper to save the newly created target") {
                                let expectedTarget = Target(name: "target", api: "concourse URL",
                                                            teamName: "main", token: Token(value: "turtle token")
                                )
                                expect(mockKeychainWrapper.capturedTarget).to(equal(expectedTarget))
                            }
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

                        it("re-enables the log in button") {
                            expect(subject.basicAuthLoginButton?.isEnabled).toEventually(beTrue())
                        }
                    }
                }

                describe("Using GitHub auth") {
                    beforeEach {
                        subject.authMethods = [AuthMethod(type: .github, url: "github-auth.com")]
                        let _ = Fleet.setInAppWindowRootNavigation(subject)
                    }

                    describe("Tapping the 'Log in with GitHub' button") {
                        beforeEach {
                            try! subject.githubAuthButton?.tap()
                        }

                        it("presents a GithubAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockGithubAuthViewController))
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect(mockGithubAuthViewController.concourseURLString).toEventually(equal("concourse URL"))
                        }

                        it("sets the auth method's auth URL on the view controller") {
                            expect(mockGithubAuthViewController.githubAuthURLString).to(equal("github-auth.com"))
                        }
                    }
                }
            }
        }
    }
}
