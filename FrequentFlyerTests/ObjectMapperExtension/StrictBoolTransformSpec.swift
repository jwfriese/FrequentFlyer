import XCTest
import ObjectMapper
import Quick
import Nimble

@testable import FrequentFlyer

class StrictBoolTransformSpec: QuickSpec {
    override func spec() {
        describe("\(StrictBoolTransform.self)") {
            var subject: StrictBoolTransform!

            beforeEach {
                subject = StrictBoolTransform()
            }

            describe("transformFromJSON:") {
                it("returns nil when input is nil") {
                    expect(subject.transformFromJSON(nil)).to(beNil())
                }

                it("handles normal bool values correctly") {
                    expect(subject.transformFromJSON("true")).to(beTrue())
                    expect(subject.transformFromJSON(true)).to(beTrue())
                    expect(subject.transformFromJSON("false")).to(beFalse())
                    expect(subject.transformFromJSON(false)).to(beFalse())
                }

                it("returns nil when input is really numeric") {
                    expect(subject.transformFromJSON(1.0)).to(beNil())
                    expect(subject.transformFromJSON(1)).to(beNil())
                    expect(subject.transformFromJSON(1.0)).to(beNil())
                }

                it("returns nil when input is some silly string") {
                    expect(subject.transformFromJSON("something else")).to(beNil())
                }
            }

            describe("transformToJSON:") {
                it("returns nil when input is nil") {
                    expect(subject.transformToJSON(nil)).to(beNil())
                }

                it("returns 'true' when given 'true'") {
                    expect(subject.transformToJSON(true)).to(equal("true"))
                }

                it("returns 'false' when given 'false'") {
                    expect(subject.transformToJSON(false)).to(equal("false"))
                }
            }
        }
    }
}
