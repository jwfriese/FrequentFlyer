import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TokenSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When all properties of the Token objects are equal") {
                let tokenOne = Token(value: "turtle token value")
                let tokenTwo = Token(value: "turtle token value")
                
                it("returns true") {
                    expect(tokenOne).to(equal(tokenTwo))
                }
            }
            
            context("When value property values of the Token objects are different") {
                let tokenOne = Token(value: "turtle token value")
                let tokenTwo = Token(value: "some other token value")
                
                it("returns false") {
                    expect(tokenOne).toNot(equal(tokenTwo))
                }
            }
        }
    }
}
