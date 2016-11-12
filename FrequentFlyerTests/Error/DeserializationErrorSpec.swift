import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class DeserializationErrorSpec: QuickSpec {
    override func spec() {
        describe("DeserializationError") {
            it("can be converted into a string") {
                let error = DeserializationError(details: "error details", type: .missingRequiredData)
                let errorString = String(describing: error)

                expect(errorString).to(equal("DeserializationError { details: \"error details\", type: \"MissingRequiredData\" }")
                )
            }

            describe("Equality operator") {
                context("When the details and types of the DeserializationError objects are equal") {
                    let errorOne = DeserializationError(details: "error", type: .invalidInputFormat)
                    let errorTwo = DeserializationError(details: "error", type: .invalidInputFormat)

                    it("returns true") {
                        expect(errorOne).to(equal(errorTwo))
                    }
                }

                context("When the details of the DeserializationError objects are equal and types are different") {
                    let errorOne = DeserializationError(details: "error", type: .invalidInputFormat)
                    let errorTwo = DeserializationError(details: "error", type: .missingRequiredData)

                    it("returns false") {
                        expect(errorOne).toNot(equal(errorTwo))
                    }
                }

                context("When the details of the DeserializationError objects are different and types are equal") {
                    let errorOne = DeserializationError(details: "error", type: .invalidInputFormat)
                    let errorTwo = DeserializationError(details: "some other error", type: .invalidInputFormat)

                    it("returns false") {
                        expect(errorOne).toNot(equal(errorTwo))
                    }
                }

                context("When the details and types of the DeserializationError objects are different") {
                    let errorOne = DeserializationError(details: "error", type: .invalidInputFormat)
                    let errorTwo = DeserializationError(details: "some other error", type: .missingRequiredData)

                    it("returns false") {
                        expect(errorOne).toNot(equal(errorTwo))
                    }
                }
            }
        }
    }
}
