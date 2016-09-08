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
    
    class MockTokenAuthService: TokenAuthService {
        var inputTeamName: String?
        var inputConcourseURL: String?
        var completionHandler: ((Token?, Error?) -> ())?
        
        override func getToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, Error?) -> ())?) {
            inputTeamName = teamName
            inputConcourseURL = concourseURL
            completionHandler = completion
        }
    }
    
    override func spec() {
        describe("AddTargetViewController") {
            var subject: AddTargetViewController!
            var mockAddTargetDelegate: MockAddTargetDelegate!
            var mockTokenAuthService: MockTokenAuthService!
            var navigationController: UINavigationController!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(AddTargetViewController.storyboardIdentifier) as! AddTargetViewController
                
                mockAddTargetDelegate = MockAddTargetDelegate()
                subject.addTargetDelegate = mockAddTargetDelegate
                
                mockTokenAuthService = MockTokenAuthService()
                subject.tokenAuthService = mockTokenAuthService
                
                navigationController = UINavigationController(rootViewController: subject)
                Fleet.setApplicationWindowRootViewController(navigationController)
            }
            
            describe("After the view has loaded") {
                it("will have the correct title") {
                    expect(subject.title).to(equal("Add Target"))
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
                    
                    it("makes a call to the token auth service using the input team and Concourse URL") {
                        expect(mockTokenAuthService.inputTeamName).to(equal("main"))
                        expect(mockTokenAuthService.inputConcourseURL).to(equal("concourse URL"))
                    }
                    
                    describe("When the token auth service call resolves with a valid token") {
                        beforeEach {
                            guard let completion = mockTokenAuthService.completionHandler else {
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
                            guard let completion = mockTokenAuthService.completionHandler else {
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
