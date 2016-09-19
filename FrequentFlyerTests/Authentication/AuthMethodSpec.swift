import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When both types and both urls are the same") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .Basic, url: ".com")
                    let methodTwo = AuthMethod(type: .Basic, url: ".com")
                    expect(methodOne).to(equal(methodTwo))
                }
            }

            context("When the auth methods are different") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .Basic, url: ".com")
                    let methodTwo = AuthMethod(type: .Github, url: ".com")
                    expect(methodOne).toNot(equal(methodTwo))
                }
            }

            context("When the urls are different") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .Basic, url: ".com")
                    let methodTwo = AuthMethod(type: .Basic, url: ".org")
                    expect(methodOne).toNot(equal(methodTwo))
                }
            }
        }
    }
}
