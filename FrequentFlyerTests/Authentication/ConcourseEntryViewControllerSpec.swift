import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class ConcourseEntryViewControllerSpec: QuickSpec {
    class MockInfoService: InfoService {
        var capturedConcourseURL: String?
        var infoSubject = PublishSubject<Info>()

        override func getInfo(forConcourseWithURL concourseURL: String) -> Observable<Info> {
            capturedConcourseURL = concourseURL
            return infoSubject
        }
    }

    class MockSSLTrustService: SSLTrustService {
        var trustedBaseURLs: [String] = []
        var hasClearedTrust =  false

        override func registerTrust(forBaseURL baseURL: String) {
            trustedBaseURLs.append(baseURL)
        }

        override func clearAllTrust() {
            hasClearedTrust = true
        }
    }

    override func spec() {
        describe("ConcourseEntryViewController") {
            var subject: ConcourseEntryViewController!
            var mockInfoService: MockInfoService!
            var mockSSLTrustService: MockSSLTrustService!
            var mockUserTextInputPageOperator: UserTextInputPageOperator!

            var mockVisibilitySelectionViewController: VisibilitySelectionViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockVisibilitySelectionViewController = try! storyboard.mockIdentifier(VisibilitySelectionViewController.storyboardIdentifier, usingMockFor: VisibilitySelectionViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: ConcourseEntryViewController.storyboardIdentifier) as! ConcourseEntryViewController

                mockInfoService = MockInfoService()
                subject.infoService = mockInfoService

                mockSSLTrustService = MockSSLTrustService()
                subject.sslTrustService = mockSSLTrustService

                mockUserTextInputPageOperator = UserTextInputPageOperator()
                subject.userTextInputPageOperator = mockUserTextInputPageOperator
            }

            describe("After the view loads") {
                var navigationController: UINavigationController!

                beforeEach {
                    navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                it("sets a blank title") {
                    expect(subject.title).to(equal(""))
                }

                it("clears SSL registry as a precaution") {
                    expect(mockSSLTrustService.hasClearedTrust).to(beTrue())
                }

                it("sets up its Concourse URL entry text field") {
                    guard let concourseURLEntryTextField = subject.concourseURLEntryField else {
                        fail("Failed to create Concourse URL entry text field")
                        return
                    }

                    expect(concourseURLEntryTextField.textField?.autocorrectionType).to(equal(UITextAutocorrectionType.no))
                    expect(concourseURLEntryTextField.textField?.keyboardType).to(equal(UIKeyboardType.URL))
                }

                it("sets itself as the UserTextInputPageOperator's delegate") {
                    expect(mockUserTextInputPageOperator.delegate).to(beIdenticalTo(subject))
                }

                describe("As a UserTextInputPageDelegate") {
                    it("returns text fields") {
                        expect(subject.textFields.count).to(equal(1))
                        expect(subject.textFields[0]).to(beIdenticalTo(subject?.concourseURLEntryField?.textField))
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
                            subject.concourseURLEntryField?.textField?.enter(text: "turtle url")
                        }

                        it("enables the button") {
                            expect(subject.submitButton!.isEnabled).to(beTrue())
                        }

                        describe("When the 'Concourse URL' field is cleared") {
                            beforeEach {
                                subject.concourseURLEntryField?.textField?.startEditing()
                                subject.concourseURLEntryField?.textField?.backspaceAll()
                                subject.concourseURLEntryField?.textField?.stopEditing()
                            }

                            it("disables the button") {
                                expect(subject.submitButton!.isEnabled).to(beFalse())
                            }
                        }
                    }
                }

                describe("Entering 'https://' and hitting 'Submit'") {
                    beforeEach {
                        subject.concourseURLEntryField?.textField?.enter(text: "https://")

                        subject.submitButton?.tap()
                    }

                    it("presents an alert informing the user that the app does not support 'http://' protocol") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Error"))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not connect to a Concourse at 'https://'."))
                    }
                }

                describe("Entering a Concourse URL with 'http://' and hitting 'Submit'") {
                    beforeEach {
                        subject.concourseURLEntryField?.textField?.enter(text: "http://badurl.com")

                        subject.submitButton?.tap()
                    }

                    it("presents an alert informing the user that the app does not support 'http://' protocol") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Unsupported Protocol"))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("This app does not support connecting to Concourse instances through HTTP. You must use HTTPS."))
                    }
                }

                describe("Entering a Concourse URL without 'https://' and hitting 'Submit'") {
                    beforeEach {
                        subject.concourseURLEntryField?.textField?.enter(text: "partial-concourse.com")

                        subject.submitButton?.tap()
                    }

                    it("disables the button") {
                        expect(subject.submitButton?.isEnabled).toEventually(beFalse())
                    }

                    it("prepends your request with `https://` and uses it to make a call to the info service") {
                        expect(mockInfoService.capturedConcourseURL).to(equal("https://partial-concourse.com"))
                    }

                    describe("When the info service call resolves with an info model") {
                        beforeEach {
                            mockInfoService.infoSubject.onNext(Info(version: "1.1.1"))
                            mockInfoService.infoSubject.onCompleted()
                        }

                        it("presents the \(VisibilitySelectionViewController.self)") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockVisibilitySelectionViewController))
                            expect(mockVisibilitySelectionViewController.concourseURLString).toEventually(equal("https://partial-concourse.com"))
                        }
                    }

                    describe("When the info service call resolves with an error") {
                        beforeEach {
                            mockInfoService.infoSubject.onError(BasicError(details: ""))
                            mockInfoService.infoSubject.onCompleted()
                        }

                        it("presents an alert informing the user that their Concourse instance could not be hit") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Error"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not connect to a Concourse at 'https://partial-concourse.com'."))
                        }

                        it("enables the button") {
                            expect(subject.submitButton?.isEnabled).toEventually(beTrue())
                        }
                    }
                }

                describe("Entering a valid Concourse URL and hitting 'Submit'") {
                    beforeEach {
                        subject.concourseURLEntryField?.textField?.enter(text: "https://concourse.com")

                        subject.submitButton?.tap()
                    }

                    it("disables the button") {
                        expect(subject.submitButton?.isEnabled).toEventually(beFalse())
                    }

                    it("uses the entered Concourse URL to make a call to the info service") {
                        expect(mockInfoService.capturedConcourseURL).to(equal("https://concourse.com"))
                    }

                    describe("When the info service call resolves successfully") {
                        beforeEach {
                            mockInfoService.infoSubject.onNext(Info(version: "1.1.1"))
                            mockInfoService.infoSubject.onCompleted()
                        }

                        it("presents the \(VisibilitySelectionViewController.self)") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockVisibilitySelectionViewController))
                            expect(mockVisibilitySelectionViewController.concourseURLString).toEventually(equal("https://concourse.com"))
                        }
                    }

                    describe("When the info service call resolves with an SSL validation error") {
                        beforeEach {
                            mockInfoService.infoSubject.onError(HTTPError.sslValidation)
                            mockInfoService.infoSubject.onCompleted()
                        }

                        it("presents an alert informing the user that SSL validation failed") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Insecure Connection"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not establish a trusted connection with the Concourse instance. Would you like to connect anyway?"))
                        }

                        describe("When the user hits the 'Cancel' button") {
                            it("dismisses the alert and enables the 'Submit' button") {
                                let screen = Fleet.getApplicationScreen()
                                var didTapCancel = false
                                let assertCancelTappedBehavior = { () -> Bool in
                                    if didTapCancel {
                                        return screen?.topmostViewController === subject
                                    }

                                    if let alert = screen?.topmostViewController as? UIAlertController {
                                        Fleet.swallowAnyErrors { alert.tapAlertAction(withTitle: "Cancel") }
                                        didTapCancel = true
                                    }

                                    return false
                                }

                                expect(assertCancelTappedBehavior()).toEventually(beTrue())
                                expect(subject.submitButton?.isEnabled).toEventually(beTrue())
                            }
                        }

                        describe("When the user hits the 'Connect' button") {
                            beforeEach {
                                // nil out so that we can test that the code calls it again
                                mockInfoService.capturedConcourseURL = nil
                            }

                            it("adds the given hostname to the \(SSLTrustService.self) and makes another call to the \(InfoService.self)") {
                                let screen = Fleet.getApplicationScreen()
                                var didTapConnect = false
                                let assertConnectTappedBehavior = { () -> Bool in
                                    if didTapConnect {
                                        return screen?.topmostViewController === subject
                                    }

                                    if let alert = screen?.topmostViewController as? UIAlertController {
                                        Fleet.swallowAnyErrors { alert.tapAlertAction(withTitle: "Connect") }
                                        didTapConnect = true
                                    }

                                    return false
                                }

                                expect(assertConnectTappedBehavior()).toEventually(beTrue())
                                expect(mockSSLTrustService.trustedBaseURLs).toEventually(contain("https://concourse.com"))
                                expect(mockInfoService.capturedConcourseURL).toEventually(equal("https://concourse.com"))
                            }
                        }
                    }

                    describe("When the info service call resolves with any other error") {
                        beforeEach {
                            mockInfoService.infoSubject.onError(BasicError(details: ""))
                            mockInfoService.infoSubject.onCompleted()
                        }

                        it("presents an alert informing the user that the app could not reach the Concourse instance") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Error"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not connect to a Concourse at 'https://concourse.com'."))
                        }

                        it("enables the button") {
                            expect(subject.submitButton?.isEnabled).toEventually(beTrue())
                        }
                    }
                }
            }
        }
    }
}
