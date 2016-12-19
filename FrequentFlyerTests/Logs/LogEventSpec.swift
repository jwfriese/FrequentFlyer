import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class LogEventSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When payloads are equal for the two LogEvent objects") {
                it("returns true") {
                    let eventOne = LogEvent(payload: "turtle payload")
                    let eventTwo = LogEvent(payload: "turtle payload")

                    expect(eventOne).to(equal(eventTwo))
                }
            }

            context("When payloads differ for the two LogEvent objects") {
                it("returns false") {
                    let eventOne = LogEvent(payload: "turtle payload")
                    let eventTwo = LogEvent(payload: "crab payload")

                    expect(eventOne).toNot(equal(eventTwo))
                }
            }
        }
    }
}
