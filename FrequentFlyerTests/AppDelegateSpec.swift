import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("AppDelegate") {
            var subject: AppDelegate!

            describe("After launching") {
                beforeEach {
                    subject = AppDelegate()
                    let application = UIApplication.sharedApplication()
                    application.delegate = subject
                    subject.application(application, didFinishLaunchingWithOptions: nil)
                }

                it("sets up the main window with a navigation controller containing a ConcourseEntryViewController and sets up the ConcourseEntryViewController with its dependencies") {
                    guard let rootNavigationController = subject.window?.rootViewController as? UINavigationController else {
                        fail("Failed to set the application window up with a navigation controller")
                        return
                    }

                    guard let concouseEntryViewController = rootNavigationController.topViewController as? ConcourseEntryViewController else {
                        fail("Failed to set root view controller as a ConcourseEntryViewController")
                        return
                    }

                    expect(concouseEntryViewController.userTextInputPageOperator).toNot(beNil())

                    guard let authMethodsService = concouseEntryViewController.authMethodsService else {
                        fail("Failed to set AuthMethodsService on the ConcourseEntryViewController")
                        return
                    }

                    expect(authMethodsService.httpClient).toNot(beNil())
                    expect(authMethodsService.authMethodsDataDeserializer).toNot(beNil())

                    guard let unauthenticatedTokenService = concouseEntryViewController.unauthenticatedTokenService else {
                        fail("Failed to set UnauthenticatedTokenService on the ConcourseEntryViewController")
                        return
                    }

                    expect(unauthenticatedTokenService.httpClient).toNot(beNil())
                    expect(unauthenticatedTokenService.tokenDataDeserializer).toNot(beNil())
                }
            }
        }
    }
}
