import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthInfoSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When all properties of the AuthInfo objects are equal") {
                let authInfoOne = AuthInfo(username: "turtle", token:Token(value: "super secret token"))
                let authInfoTwo = AuthInfo(username: "turtle", token:Token(value: "super secret token"))

                it("returns true") {
                    expect(authInfoOne).to(equal(authInfoTwo))
                }
            }

            context("When the 'username' values of the AuthInfo objects differ") {
                let authInfoOne = AuthInfo(username: "turtle", token:Token(value: "super secret token"))
                let authInfoTwo = AuthInfo(username: "crab", token:Token(value: "super secret token"))

                it("returns false") {
                    expect(authInfoOne).toNot(equal(authInfoTwo))
                }
            }

            context("When the 'token' values of the AuthInfo objects differ") {
                let authInfoOne = AuthInfo(username: "turtle", token:Token(value: "super secret token"))
                let authInfoTwo = AuthInfo(username: "turtle", token:Token(value: "some other secret token"))

                it("returns false") {
                    expect(authInfoOne).toNot(equal(authInfoTwo))
                }
            }
        }

        describe("Saveability to the keychain") {
            it("has a static variable for service name") {
                expect(AuthInfo.serviceName).to(equal("Authentication"))
            }

            it("can produce data to save") {
                let authInfo = AuthInfo(username: "turtle", token:Token(value: "super secret token"))
                expect(authInfo.data["username"] as? String).to(equal("turtle"))
                expect(authInfo.data["token"] as? String).to(equal("super secret token"))
            }
        }
    }
}
