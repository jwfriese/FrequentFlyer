import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class LogsStylingParserSpec: QuickSpec {
    override func spec() {
        describe("LogsStylingParser") {
            var subject: LogsStylingParser!

            beforeEach {
                subject = LogsStylingParser()
            }

            describe("Stripping color coding out of a string") {
                var result: String!

                describe("When the input string has no styling codes") {
                    beforeEach {
                        result = subject.stripStylingCoding(originalString: "original string")
                    }

                    it("returns the input string untouched") {
                        expect(result).to(equal("original string"))
                    }
                }

                describe("When the input string has well-formed styling codes") {
                    beforeEach {
                        result = subject.stripStylingCoding(originalString: "t[1m[32murt[0ml[36m[1me[0m")
                    }

                    it("returns the input string with all styling codes removed") {
                        expect(result).to(equal("turtle"))
                    }
                }
            }
        }
    }
}
