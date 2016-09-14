import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class AddTargetViewControllerSpec: QuickSpec {
    class MockAddTargetDelegate: AddTargetDelegate {
        var addedTarget: Target?

        func onTargetAdded(target: Target) {
            addedTarget = target
        }
    }

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

    override func spec() {
        describe("AddTargetViewController") {
            var subject: AddTargetViewController!
            var mockAddTargetDelegate: MockAddTargetDelegate!
            var mockAuthMethodsService: MockAuthMethodsService!
            var mockUnauthenticatedTokenService: MockUnauthenticatedTokenService!
            var mockUserTextInputPageOperator: UserTextInputPageOperator!

            var navigationController: UINavigationController!
            var mockAuthCredentialsViewController: AuthCredentialsViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mockAuthCredentialsViewController = AuthCredentialsViewController()
                try! storyboard.bindViewController(mockAuthCredentialsViewController, toIdentifier: AuthCredentialsViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(AddTargetViewController.storyboardIdentifier) as! AddTargetViewController

                mockAddTargetDelegate = MockAddTargetDelegate()
                subject.addTargetDelegate = mockAddTargetDelegate

                mockAuthMethodsService = MockAuthMethodsService()
                subject.authMethodsService = mockAuthMethodsService

                mockUnauthenticatedTokenService = MockUnauthenticatedTokenService()
                subject.unauthenticatedTokenService = mockUnauthenticatedTokenService

                mockUserTextInputPageOperator = UserTextInputPageOperator()
                subject.userTextInputPageOperator = mockUserTextInputPageOperator

                navigationController = UINavigationController(rootViewController: subject)
                Fleet.setApplicationWindowRootViewController(navigationController)
            }

            describe("After the view has loaded") {
                it("has the correct title") {
                    expect(subject.title).to(equal("Add Target"))
                }

                it("sets itself as the delegate for its UserTextInputPageOperator") {
                    expect(mockUserTextInputPageOperator.delegate).to(beIdenticalTo(subject))
                }

                describe("As a UserTextInputPageDelegate") {
                    it("provides its text views") {
                        expect(subject.textFields).to(contain([subject.targetNameTextField, subject.concourseURLTextField]))
                    }

                    it("provides a screen view") {
                        expect(subject.pageView).to(beIdenticalTo(subject.view))
                    }

                    it("provides a scroll view") {
                        expect(subject.pageScrollView).to(beIdenticalTo(subject.scrollView))
                    }
                }

                describe("Availability of the 'Add Target' button") {
                    it("is disabled just after the view is loaded") {
                        expect(subject.addTargetButton!.enabled).to(beFalse())
                    }

                    describe("When only the 'Target Name' field has text") {
                        beforeEach {
                            try! subject.targetNameTextField?.enterText("turtle target")
                        }

                        it("leaves the button disabled") {
                            expect(subject.addTargetButton!.enabled).to(beFalse())
                        }
                    }

                    describe("When only the 'Concourse URL' field has text") {
                        beforeEach {
                            try! subject.concourseURLTextField?.enterText("Concourse turtle")
                        }

                        it("leaves the button disabled") {
                            expect(subject.addTargetButton!.enabled).to(beFalse())
                        }
                    }

                    describe("When both the 'Target Name' field and the 'Concourse URL' field have text") {
                        beforeEach {
                            try! subject.targetNameTextField?.enterText("turtle target")
                            try! subject.concourseURLTextField?.enterText("Concourse turtle")
                        }

                        it("enables the button") {
                            expect(subject.addTargetButton!.enabled).to(beTrue())
                        }

                        describe("When the 'Target Name' field is cleared") {
                            beforeEach {
                                subject.targetNameTextField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.addTargetButton!.enabled).to(beFalse())
                            }
                        }

                        describe("When the 'Concourse URL' field is cleared") {
                            beforeEach {
                                subject.concourseURLTextField?.clearText()
                            }

                            it("disables the button") {
                                expect(subject.addTargetButton!.enabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Entering target information and hitting the 'Add Target' button") {
                    beforeEach {
                        try! subject.targetNameTextField?.enterText("turtle target")
                        try! subject.concourseURLTextField?.enterText("concourse URL")

                        subject.addTargetButton?.tap()
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

                        it("sets up and presents a modal to get authentication credentials") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockAuthCredentialsViewController))
                        }

                        it("sets itself as the AuthServiceConsumer of the modal") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? AuthCredentialsViewController)?.authServiceConsumer).toEventually(beIdenticalTo(subject))
                        }

                        it("sets a BasicAuthTokenService on the modal") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? AuthCredentialsViewController)?.basicAuthTokenService).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? AuthCredentialsViewController)?.basicAuthTokenService?.httpClient).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? AuthCredentialsViewController)?.basicAuthTokenService?.tokenDataDeserializer).toEventuallyNot(beNil())
                        }

                        it("sets the entered Concourse URL on the modal") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? AuthCredentialsViewController)?.concourseURLString).toEventually(equal("concourse URL"))
                        }

                        describe("When the modal finishes collecting credentials") {
                            beforeEach {
                                subject.onAuthenticationCompleted(withToken: Token(value: "turtle token"))
                            }

                            it("dismisses the auth credentials modal") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(subject))
                            }

                            it("creates a target using the token and all other entered information and passes it to the delegate") {
                                let expectedTarget = Target(name: "turtle target",
                                                            api: "concourse URL",
                                                            teamName: "main",
                                                            token: Token(value: "turtle token")
                                )

                                expect(mockAddTargetDelegate.addedTarget).toEventually(equal(expectedTarget))
                            }
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

                            it("creates a new target from the entered information and passes it to the delegate") {
                                let expectedTarget = Target(name: "turtle target", api: "concourse URL",
                                                            teamName: "main", token: Token(value: "turtle auth token")
                                )
                                expect(mockAddTargetDelegate.addedTarget).to(equal(expectedTarget))
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
