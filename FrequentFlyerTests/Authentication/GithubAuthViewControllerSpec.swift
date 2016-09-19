import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class GithubAuthViewControllerSpec: QuickSpec {
    class MockKeychainWrapper: KeychainWrapper {
        var capturedAuthInfo: AuthInfo?
        var capturedTargetName: String?

        override func saveAuthInfo(authInfo: AuthInfo, forTargetWithName targetName: String) {
            capturedAuthInfo = authInfo
            capturedTargetName = targetName
        }
    }

    class MockBrowserAgent: BrowserAgent {
        var capturedURL: NSURL?

        override func openInBrowser(url: NSURL) {
            capturedURL = url
        }
    }

    class MockTokenValidationService: TokenValidationService {
        var capturedToken: Token?
        var capturedConcourseURLString: String?
        var capturedCompletion: ((Error?) -> ())?

        override func validate(token token: Token, forConcourse concourseURLString: String, completion: ((Error?) -> ())?) {
            capturedToken = token
            capturedConcourseURLString = concourseURLString
            capturedCompletion = completion
        }
    }

    class MockTeamPipelinesViewController: TeamPipelinesViewController {
        override func viewDidLoad() { }
    }

    override func spec() {
        describe("GithubAuthViewController") {
            var subject: GithubAuthViewController!
            var mockKeychainWrapper: MockKeychainWrapper!
            var mockBrowserAgent: MockBrowserAgent!
            var mockTokenValidationService: MockTokenValidationService!
            var mockUserTextInputPageOperator: UserTextInputPageOperator!

            var mockTeamPipelinesViewController: MockTeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamPipelinesViewController = MockTeamPipelinesViewController()
                try! storyboard.bindViewController(mockTeamPipelinesViewController, toIdentifier: TeamPipelinesViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(GithubAuthViewController.storyboardIdentifier) as! GithubAuthViewController

                subject.concourseURLString = "turtle_concourse.com"
                subject.githubAuthURLString = "turtle_github.com"

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper

                mockBrowserAgent = MockBrowserAgent()
                subject.browserAgent = mockBrowserAgent

                mockTokenValidationService = MockTokenValidationService()
                subject.tokenValidationService = mockTokenValidationService

                mockUserTextInputPageOperator = UserTextInputPageOperator()
                subject.userTextInputPageOperator = mockUserTextInputPageOperator
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }

                it("sets a blank title") {
                    expect(subject.title).to(equal(""))
                }

                it("sets itself as its token text field's delegate") {
                    expect(subject.tokenTextField?.delegate).to(beIdenticalTo(subject))
                }

                it("sets itself as its UserTextInputPageOperator's delegate") {
                    expect(mockUserTextInputPageOperator.delegate).to(beIdenticalTo(subject))
                }

                describe("As a UserTextInputPageDelegate") {
                    it("returns text fields") {
                        expect(subject.textFields.count).to(equal(1))
                        expect(subject.textFields[0]).to(beIdenticalTo(subject?.tokenTextField))
                    }

                    it("returns a page view") {
                        expect(subject.pageView).to(beIdenticalTo(subject.view))
                    }

                    it("returns a page scrolls view") {
                        expect(subject.pageScrollView).to(beIdenticalTo(subject.scrollView))
                    }
                }

                describe("Availability of the 'Get Token' button") {
                    it("is always enabled") {
                        expect(subject.openGithubAuthPageButton?.enabled).to(beTrue())
                    }
                }

                describe("Availability of the 'Submit' button") {
                    it("is disabled just after the view is loaded") {
                        expect(subject.submitButton!.enabled).to(beFalse())
                    }

                    describe("When the 'Token' field has text") {
                        beforeEach {
                            try! subject.tokenTextField?.enterText("token of the Github Turtle")
                        }

                        it("enables the button") {
                            expect(subject.submitButton!.enabled).to(beTrue())
                        }

                        describe("When the 'Token' field is cleared") {
                            beforeEach {
                                subject.tokenTextField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.enabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Tapping on the 'Get Token' button") {
                    beforeEach {
                        subject.openGithubAuthPageButton?.tap()
                    }

                    it("asks the BrowserAgent to open the Github auth URL") {
                        guard let url = mockBrowserAgent.capturedURL else {
                            fail("Failed to call the BrowserAgent with Github auth URL")
                            return
                        }

                        expect(url.absoluteString).to(equal("turtle_github.com"))
                    }
                }

                describe("Entering a token and hitting the 'Submit' button") {
                    beforeEach {
                        try! subject.tokenTextField?.enterText("token of the Github Turtle")
                        subject.submitButton?.tap()
                    }

                    it("uses the token verification service to check that the token is valid") {
                        expect(mockTokenValidationService.capturedToken).to(equal(Token(value: "token of the Github Turtle")))
                        expect(mockTokenValidationService.capturedConcourseURLString).to(equal("turtle_concourse.com"))
                    }

                    describe("When the validation call returns with no error") {
                        describe("When 'Stay Logged In' switch is off") {
                            beforeEach {
                                subject.stayLoggedInSwitch?.on = false

                                guard let completion = mockTokenValidationService.capturedCompletion else {
                                    fail("Failed to call TokenValidationService with a completion handler")
                                    return
                                }

                                completion(nil)
                            }

                            it("does not save anything to the keychain") {
                                expect(mockKeychainWrapper.capturedAuthInfo).to(beNil())
                                expect(mockKeychainWrapper.capturedTargetName).to(beNil())
                            }

                            it("replaces itself with the TeamPipelinesViewController") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                            }

                            it("creates a new target from the entered information and view controller") {
                                let expectedTarget = Target(name: "target", api: "turtle_concourse.com",
                                                            teamName: "main", token: Token(value: "token of the Github Turtle")
                                )
                                expect(mockTeamPipelinesViewController.target).toEventually(equal(expectedTarget))
                            }

                            it("sets a TeamPipelinesService on the view controller") {
                                expect(mockTeamPipelinesViewController.teamPipelinesService).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.httpClient).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.pipelineDataDeserializer).toEventuallyNot(beNil())
                            }
                        }

                        describe("When 'Stay Logged In' switch is on") {
                            beforeEach {
                                subject.stayLoggedInSwitch?.on = true

                                guard let completion = mockTokenValidationService.capturedCompletion else {
                                    fail("Failed to call TokenValidationService with a completion handler")
                                    return
                                }

                                completion(nil)
                            }

                            it("asks the KeychainWrapper to save the authentication info for this target") {
                                expect(mockKeychainWrapper.capturedAuthInfo).to(equal(AuthInfo(username: "user", token: Token(value: "token of the Github Turtle"))))
                                expect(mockKeychainWrapper.capturedTargetName).to(equal("target"))
                            }

                            it("replaces itself with the TeamPipelinesViewController") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                            }

                            it("creates a new target from the entered information and view controller") {
                                let expectedTarget = Target(name: "target", api: "turtle_concourse.com",
                                                            teamName: "main", token: Token(value: "token of the Github Turtle")
                                )
                                expect(mockTeamPipelinesViewController.target).toEventually(equal(expectedTarget))
                            }

                            it("sets a TeamPipelinesService on the view controller") {
                                expect(mockTeamPipelinesViewController.teamPipelinesService).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.httpClient).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.pipelineDataDeserializer).toEventuallyNot(beNil())
                            }
                        }
                    }

                    describe("When the validation call returns with an error") {
                        beforeEach {
                            guard let completion = mockTokenValidationService.capturedCompletion else {
                                fail("Failed to call TokenValidationService with a completion handler")
                                return
                            }

                            completion(BasicError(details: "validation error"))
                        }

                        it("displays an alert containing the error that came from the HTTP call") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                            let screen = Fleet.getApplicationScreen()
                            expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                            let alert = screen?.topmostViewController as? UIAlertController
                            expect(alert?.title).toEventually(equal("Authorization Failed"))
                            expect(alert?.message).toEventually(equal("validation error"))
                        }
                    }
                }
            }
        }
    }
}
