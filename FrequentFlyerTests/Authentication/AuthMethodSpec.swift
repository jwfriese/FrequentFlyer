import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When both types are the same") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .Basic)
                    let methodTwo = AuthMethod(type: .Basic)
                    expect(methodOne).to(equal(methodTwo))
                }
            }
            
            context("When the auth methods are different") {
                it("returns true") {
                    let methodOne = AuthMethod(type: .Basic)
                    let methodTwo = AuthMethod(type: .Github)
                    expect(methodOne).toNot(equal(methodTwo))
                }
            }
        }
    }
}
