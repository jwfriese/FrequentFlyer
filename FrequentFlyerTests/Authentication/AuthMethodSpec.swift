import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            it("always returns true because there is only one type of AuthMethod") {
                let methodOne = AuthMethod(type: .Basic)
                let methodTwo = AuthMethod(type: .Basic)
                expect(methodOne).to(equal(methodTwo))
            }
        }
    }
}
