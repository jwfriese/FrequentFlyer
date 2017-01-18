import XCTest
import Quick
import Nimble
import Fleet
import RxSwift
@testable import FrequentFlyer

class ConcourseEntryViewControllerSpec: QuickSpec {
    class MockAuthMethodsService: AuthMethodsService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var authMethodsSubject = PublishSubject<AuthMethod>()

        override func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<AuthMethod> {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            return authMethodsSubject
        }
    }

    class MockUnauthenticatedTokenService: UnauthenticatedTokenService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var capturedCompletionHandler: ((Token?, FFError?) -> ())?

        override func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, FFError?) -> ())?) {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            capturedCompletionHandler = completion
        }
    }

    override func spec() {
        describe("ConcourseEntryViewController") {
            var subject: ConcourseEntryViewController!
            var mockAuthMethodsService: MockAuthMethodsService!
            var mockUnauthenticatedTokenService: MockUnauthenticatedTokenService!
            var mockUserTextInputPageOperator: UserTextInputPageOperator!

            var mockAuthMethodListViewController: AuthMethodListViewController!
            var mockTeamPipelinesViewController: TeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockAuthMethodListViewController = try! storyboard.mockIdentifier(AuthMethodListViewController.storyboardIdentifier, usingMockFor: AuthMethodListViewController.self)

                mockTeamPipelinesViewController = try! storyboard.mockIdentifier(TeamPipelinesViewController.storyboardIdentifier, usingMockFor: TeamPipelinesViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: ConcourseEntryViewController.storyboardIdentifier) as! ConcourseEntryViewController

                mockAuthMethodsService = MockAuthMethodsService()
                subject.authMethodsService = mockAuthMethodsService

                mockUnauthenticatedTokenService = MockUnauthenticatedTokenService()
                subject.unauthenticatedTokenService = mockUnauthenticatedTokenService

                mockUserTextInputPageOperator = UserTextInputPageOperator()
                subject.userTextInputPageOperator = mockUserTextInputPageOperator
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

                    expect(concourseURLEntryTextField.autocorrectionType).to(equal(UITextAutocorrectionType.no))
                    expect(concourseURLEntryTextField.keyboardType).to(equal(UIKeyboardType.URL))
                }

                it("sets itself as the UserTextInputPageOperator's delegate") {
                    expect(mockUserTextInputPageOperator.delegate).to(beIdenticalTo(subject))
                }

                describe("As a UserTextInputPageDelegate") {
                    it("returns text fields") {
                        expect(subject.textFields.count).to(equal(1))
                        expect(subject.textFields[0]).to(beIdenticalTo(subject?.concourseURLEntryField))
                    }

                    it("returns a page view") {
                        expect(subject.pageView).to(beIdenticalTo(subject.view))
                    }

                    it("returns a page scrolls view") {
                        expect(subject.pageScrollView).to(beIdenticalTo(subject.scrollView))
                    }
                }

                describe("Availability of the 'Submit' button") {
                    it("is disabled just after the view is loaded") {
                        expect(subject.submitButton?.isEnabled).to(beFalse())
                    }

                    describe("When the 'Concourse URL' field has text") {
                        beforeEach {
                            try! subject.concourseURLEntryField?.enter(text: "turtle url")
                        }

                        it("enables the button") {
                            expect(subject.submitButton!.isEnabled).to(beTrue())
                        }

                        describe("When the 'Concourse URL' field is cleared") {
                            beforeEach {
                                subject.concourseURLEntryField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.isEnabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Entering a Concourse URL and hitting 'Submit'") {
                    var authMethodStreamResult: StreamResult<AuthMethod>!

                    beforeEach {
                        authMethodStreamResult = StreamResult(mockAuthMethodsService.authMethodsSubject)

                        try! subject.concourseURLEntryField?.enter(text: "concourse URL")

                        subject.submitButton?.tap()
                    }

                    func returnAuthMethods(_ methods: [AuthMethod]) {
                        let methodSubject = mockAuthMethodsService.authMethodsSubject
                        for method in methods { methodSubject.onNext(method) }
                        methodSubject.onCompleted()
                    }

                    it("makes a call to the auth methods service using the input team and Concourse URL") {
                        expect(mockAuthMethodsService.capturedTeamName).to(equal("main"))
                        expect(mockAuthMethodsService.capturedConcourseURL).to(equal("concourse URL"))
                    }

                    describe("When the auth methods service call resolves with some auth methods and no error") {
                        beforeEach {
                            let basicAuthMethod = AuthMethod(type: .basic, url: "basic-auth.com")
                            let githubAuthMethod = AuthMethod(type: .github, url: "github-auth.com")
                            returnAuthMethods([basicAuthMethod, githubAuthMethod])
                        }

                        it("presents an AuthMethodListViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockAuthMethodListViewController))
                        }

                        it("sets the fetched auth methods on the view controller") {
                            expect(authMethodStreamResult.elements).toEventually(equal([
                                AuthMethod(type: .basic, url: "basic-auth.com"),
                                AuthMethod(type: .github, url: "github-auth.com")
                                ]))
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect(mockAuthMethodListViewController.concourseURLString).toEventually(equal("concourse URL"))
                        }
                    }

                    describe("When the auth methods service call resolves with no auth methods and no error") {
                        beforeEach {
                            returnAuthMethods([])
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
