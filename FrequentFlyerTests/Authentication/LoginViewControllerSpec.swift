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
        var tokenSubject = PublishSubject<Token>()

        override func getToken(forTeamWithName teamName: String, concourseURL: String, username: String, password: String) -> Observable<Token> {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedUsername = username
            capturedPassword = password
            return tokenSubject
        }
    }

    class MockKeychainWrapper: KeychainWrapper {
        var capturedTarget: Target?

        override func saveTarget(_ target: Target) {
            capturedTarget = target
        }
    }

    override func spec() {
        describe("LoginViewController") {
            var subject: LoginViewController!
            var mockBasicAuthTokenService: MockBasicAuthTokenService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockTeamPipelinesViewController: TeamPipelinesViewController!
            var mockGitHubAuthViewController: GitHubAuthViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamPipelinesViewController = try! storyboard.mockIdentifier(TeamPipelinesViewController.storyboardIdentifier, usingMockFor: TeamPipelinesViewController.self)

                mockGitHubAuthViewController = try! storyboard.mockIdentifier(GitHubAuthViewController.storyboardIdentifier, usingMockFor: GitHubAuthViewController.self)

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
                            expect(subject.stayLoggedInToggle?.isHidden).to(beFalse())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beFalse())
                        }

                        it("hides the GitHub auth section") {
                            expect(subject.gitHubAuthDisplayLabel?.isHidden).to(beTrue())
                            expect(subject.gitHubAuthButton?.isHidden).to(beTrue())
                        }
                    }

                    context("When only GitHub auth is available") {
                        beforeEach {
                            subject.authMethods = [AuthMethod(type: .gitHub, url: "gitHub-auth.com")]
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("hides the username and password entry fields") {
                            expect(subject.usernameField?.isHidden).to(beTrue())
                            expect(subject.passwordField?.isHidden).to(beTrue())
                            expect(subject.stayLoggedInToggle?.isHidden).to(beTrue())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beTrue())
                        }

                        it("displays the GitHub auth section") {
                            expect(subject.gitHubAuthDisplayLabel?.isHidden).to(beFalse())
                            expect(subject.gitHubAuthButton?.isHidden).to(beFalse())
                        }
                    }

                    context("When both basic auth and GitHub auth are available") {
                        beforeEach {
                            subject.authMethods = [
                                AuthMethod(type: .basic, url: "basic-auth.com"),
                                AuthMethod(type: .gitHub, url: "gitHub-auth.com")
                            ]

                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("displays the username and password entry fields") {
                            expect(subject.usernameField?.isHidden).to(beFalse())
                            expect(subject.passwordField?.isHidden).to(beFalse())
                            expect(subject.stayLoggedInToggle?.isHidden).to(beFalse())
                            expect(subject.basicAuthLoginButton?.isHidden).to(beFalse())
                        }

                        it("displays the GitHub auth section") {
                            expect(subject.gitHubAuthDisplayLabel?.isHidden).to(beFalse())
                            expect(subject.gitHubAuthButton?.isHidden).to(beFalse())
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
                        describe("When the 'Stay logged in?' toggle is off") {
                            beforeEach {
                                subject.stayLoggedInToggle?.checkBox?.on = false

                                let token = Token(value: "turtle token")
                                mockBasicAuthTokenService.tokenSubject.onNext(token)
                                mockBasicAuthTokenService.tokenSubject.onCompleted()
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

                        describe("When the 'Stay logged in?' toggle is on") {
                            beforeEach {
                                subject.stayLoggedInToggle?.checkBox?.on = true

                                let token = Token(value: "turtle token")
                                mockBasicAuthTokenService.tokenSubject.onNext(token)
                                mockBasicAuthTokenService.tokenSubject.onCompleted()
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
                            let error = BasicError(details: "turtle authentication error")
                            mockBasicAuthTokenService.tokenSubject.onError(error)
                        }

                        it("displays an alert containing the error that came from the HTTP call") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                            let screen = Fleet.getApplicationScreen()
                            expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                            let alert = screen?.topmostViewController as? UIAlertController
                            expect(alert?.title).toEventually(equal("Authorization Failed"))
                            expect(alert?.message).toEventually(equal("Please check that the username and password you entered are correct."))
                        }

                        it("re-enables the log in button") {
                            expect(subject.basicAuthLoginButton?.isEnabled).toEventually(beTrue())
                        }
                    }
                }

                describe("Using GitHub auth") {
                    beforeEach {
                        subject.authMethods = [AuthMethod(type: .gitHub, url: "gitHub-auth.com")]
                        let _ = Fleet.setInAppWindowRootNavigation(subject)
                    }

                    describe("Tapping the 'Log in with GitHub' button") {
                        beforeEach {
                            try! subject.gitHubAuthButton?.tap()
                        }

                        it("presents a GitHubAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockGitHubAuthViewController))
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect(mockGitHubAuthViewController.concourseURLString).toEventually(equal("concourse URL"))
                        }

                        it("sets the auth method's auth URL on the view controller") {
                            expect(mockGitHubAuthViewController.gitHubAuthURLString).to(equal("gitHub-auth.com"))
                        }
                    }
                }
            }
        }
    }
}
