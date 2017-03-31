import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TokenSpec: QuickSpec {
    override func spec() {
        describe("Token.authValue") {
            context("When the token's value already includes 'Bearer ' as a prefix") {
                it("returns the existing token value") {
                    let token = Token(value: "Bearer value")
                    expect(token.value).to(equal("Bearer value"))
                    expect(token.authValue).to(equal("Bearer value"))
                }
            }

            context("When the token's value does NOT contain a 'Bearer' prefix") {
                it("returns a string prepended with 'Bearer'") {
                    let token = Token(value: "another value")
                    expect(token.value).to(equal("another value"))
                    expect(token.authValue).to(equal("Bearer another value"))
                }
            }
        }
    }
}
