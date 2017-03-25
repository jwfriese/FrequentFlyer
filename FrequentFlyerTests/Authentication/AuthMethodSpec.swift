import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When both types and both urls are the same") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .basic, url: ".com")
                    let methodTwo = AuthMethod(type: .basic, url: ".com")
                    expect(methodOne).to(equal(methodTwo))
                }
            }

            context("When the auth methods are different") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .basic, url: ".com")
                    let methodTwo = AuthMethod(type: .gitHub, url: ".com")
                    expect(methodOne).toNot(equal(methodTwo))
                }
            }

            context("When the urls are different") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .basic, url: ".com")
                    let methodTwo = AuthMethod(type: .basic, url: ".org")
                    expect(methodOne).toNot(equal(methodTwo))
                }
            }
        }
    }
}
