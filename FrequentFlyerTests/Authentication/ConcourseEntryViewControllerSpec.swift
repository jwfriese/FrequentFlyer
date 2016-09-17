import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class ConcourseEntryViewControllerSpec: QuickSpec {
    class MockAuthMethodsService: AuthMethodsService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var capturedCompletion: (([AuthMethod]?, Error?) -> ())?

        override func getMethods(forTeamName teamName: String, concourseURL: String, completion: (([AuthMethod]?, Error?) -> ())?) {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedCompletion = completion
        }
    }

    class MockUnauthenticatedTokenService: UnauthenticatedTokenService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var capturedCompletionHandler: ((Token?, Error?) -> ())?

        override func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, Error?) -> ())?) {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedCompletionHandler = completion
        }
    }

    class MockBasicUserAuthViewController: BasicUserAuthViewController {
        override func viewDidLoad() { }
    }

    class MockTeamPipelinesViewController: TeamPipelinesViewController {
        override func viewDidLoad() { }
    }

    override func spec() {
        describe("ConcourseEntryViewController") {
            var subject: ConcourseEntryViewController!
            var mockAuthMethodsService: MockAuthMethodsService!
            var mockUnauthenticatedTokenService: MockUnauthenticatedTokenService!

            var mockBasicUserAuthViewController: MockBasicUserAuthViewController!
            var mockTeamPipelinesViewController: MockTeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockBasicUserAuthViewController = MockBasicUserAuthViewController()
                try! storyboard.bindViewController(mockBasicUserAuthViewController, toIdentifier: BasicUserAuthViewController.storyboardIdentifier)

                mockTeamPipelinesViewController = MockTeamPipelinesViewController()
                try! storyboard.bindViewController(mockTeamPipelinesViewController, toIdentifier: TeamPipelinesViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(ConcourseEntryViewController.storyboardIdentifier) as! ConcourseEntryViewController

                mockAuthMethodsService = MockAuthMethodsService()
                subject.authMethodsService = mockAuthMethodsService

                mockUnauthenticatedTokenService = MockUnauthenticatedTokenService()
                subject.unauthenticatedTokenService = mockUnauthenticatedTokenService
            }

            describe("After the view loads") {
                var navigationController: UINavigationController!

                beforeEach {
                    navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }

                it("sets a blank title") {
                    expect(subject.title).to(equal(""))
                }

                it("sets up its Concourse URL entry text field") {
                    guard let concourseURLEntryTextField = subject.concourseURLEntryField else {
                        fail("Failed to create Concourse URL entry text field")
                        return
                    }

                    expect(concourseURLEntryTextField.autocorrectionType).to(equal(UITextAutocorrectionType.No))
                    expect(concourseURLEntryTextField.keyboardType).to(equal(UIKeyboardType.URL))
                }

                describe("Availability of the 'Submit' button") {
                    it("is disabled just after the view is loaded") {
                        expect(subject.submitButton?.enabled).to(beFalse())
                    }

                    describe("When the 'Concourse URL' field has text") {
                        beforeEach {
                            try! subject.concourseURLEntryField?.enterText("turtle url")
                        }

                        it("enables the button") {
                            expect(subject.submitButton!.enabled).to(beTrue())
                        }

                        describe("When the 'Concourse URL' field is cleared") {
                            beforeEach {
                                subject.concourseURLEntryField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.enabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Entering a Concourse URL and hitting 'Submit'") {
                    beforeEach {
                        try! subject.concourseURLEntryField?.enterText("concourse URL")
                        subject.submitButton?.tap()
                    }

                    it("makes a call to the auth methods service using the input team and Concourse URL") {
                        expect(mockAuthMethodsService.capturedTeamName).to(equal("main"))
                        expect(mockAuthMethodsService.capturedConcourseURL).to(equal("concourse URL"))
                    }

                    describe("When the auth methods service call resolves with a basic auth method and no error") {
                        beforeEach {
                            guard let completion = mockAuthMethodsService.capturedCompletion else {
                                fail("Failed to pass completion handler to AuthMethodsService")
                                return
                            }

                            let authMethod = AuthMethod(type: .Basic)
                            completion([authMethod], nil)
                        }

                        it("presents a BasicUserAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockBasicUserAuthViewController))
                        }

                        it("sets a BasicAuthTokenService on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService?.httpClient).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService?.tokenDataDeserializer).toEventuallyNot(beNil())
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.concourseURLString).toEventually(equal("concourse URL"))
                        }

                        it("sets a KeychainWrapper on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.keychainWrapper).toEventuallyNot(beNil())
                        }
                    }

                    describe("When the auth methods service call resolves with no auth methods and no error") {
                        beforeEach {
                            guard let completion = mockAuthMethodsService.capturedCompletion else {
                                fail("Failed to pass completion handler to AuthMethodsService")
                                return
                            }

                            completion([], nil)
                        }

                        it("makes a call to the token auth service using the input team, Concourse URL, and no other credentials") {
                            expect(mockUnauthenticatedTokenService.capturedTeamName).to(equal("main"))
                            expect(mockUnauthenticatedTokenService.capturedConcourseURL).to(equal("concourse URL"))
                        }

                        describe("When the token auth service call resolves with a valid token") {
                            beforeEach {
                                guard let completion = mockUnauthenticatedTokenService.capturedCompletionHandler else {
                                    fail("Failed to call token auth service with a completion handler")
                                    return
                                }

                                let token = Token(value: "turtle auth token")
                                completion(token, nil)
                            }

                            it("replaces itself with the TeamPipelinesViewController") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamPipelinesViewController))
                            }

                            it("creates a new target from the entered information and view controller") {
                                let expectedTarget = Target(name: "target", api: "concourse URL",
                                                            teamName: "main", token: Token(value: "turtle auth token")
                                )
                                expect(mockTeamPipelinesViewController.target).toEventually(equal(expectedTarget))
                            }

                            it("sets a TeamPipelinesService on the view controller") {
                                expect(mockTeamPipelinesViewController.teamPipelinesService).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.httpClient).toEventuallyNot(beNil())
                                expect(mockTeamPipelinesViewController.teamPipelinesService?.pipelineDataDeserializer).toEventuallyNot(beNil())
                            }
                        }

                        describe("When the token auth service call resolves with some error") {
                            beforeEach {
                                guard let completion = mockUnauthenticatedTokenService.capturedCompletionHandler else {
                                    fail("Failed to call token auth service with a completion handler")
                                    return
                                }

                                let error = BasicError(details: "error details")
                                completion(nil, error)
                            }

                            it("presents an alert that contains the error message from the token auth service") {
                                expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                                let screen = Fleet.getApplicationScreen()
                                expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                                let alert = screen?.topmostViewController as? UIAlertController
                                expect(alert?.title).toEventually(equal("Authorization Failed"))
                                expect(alert?.message).toEventually(equal("error details"))
                            }
                        }
                    }
                }
            }
        }
    }
}
