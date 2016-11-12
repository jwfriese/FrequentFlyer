import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BasicErrorSpec: QuickSpec {
    override func spec() {
        describe("BasicError") {
            it("can be converted into a string") {
                let error = BasicError(details: "error details")
                let errorString = String(describing: error)

                expect(errorString).to(equal("Error { details: \"error details\" }"))
            }

            describe("Equality operator") {
                context("When the details of the BasicError objects are equal") {
                    let errorOne = BasicError(details: "error")
                    let errorTwo = BasicError(details: "error")

                    it("returns true") {
                        expect(errorOne).to(equal(errorTwo))
                    }
                }

                context("When the details of the BasicError objects are different") {
                    let errorOne = BasicError(details: "error")
                    let errorTwo = BasicError(details: "some other error")

                    it("returns false") {
                        expect(errorOne).toNot(equal(errorTwo))
                    }
                }
            }
        }
    }
}
