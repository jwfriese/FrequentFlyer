import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class PipelineSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When the two Pipeline objects have the same name") {
                it("returns true") {
                    let pipelineOne = Pipeline(name: "turtle pipeline")
                    let pipelineTwo = Pipeline(name: "turtle pipeline")
                    
                    expect(pipelineOne).to(equal(pipelineTwo))
                }
            }
            
            context("When the two Pipeline objects have different names") {
                it("returns true") {
                    let pipelineOne = Pipeline(name: "turtle pipeline")
                    let pipelineTwo = Pipeline(name: "crab pipeline")
                    
                    expect(pipelineOne).toNot(equal(pipelineTwo))
                }
            }
        }
    }
}
