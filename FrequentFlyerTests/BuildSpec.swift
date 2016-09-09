import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BuildSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When all properties are equal for the two Build objects") {
                it("returns true") {
                    let buildOne = Build(id: 2, jobName: "job name", status: "status")
                    let buildTwo = Build(id: 2, jobName: "job name", status: "status")
                    expect(buildOne).to(equal(buildTwo))
                }
            }
            
            context("When the 'id' property differs for the two Build objects") {
                it("returns true") {
                    let buildOne = Build(id: 2, jobName: "job name", status: "status")
                    let buildTwo = Build(id: 1, jobName: "job name", status: "status")
                    expect(buildOne).to(equal(buildTwo))
                }
            }
            
            context("When the 'jobName' property differs for the two Build objects") {
                it("returns false") {
                    let buildOne = Build(id: 2, jobName: "job name 1", status: "status")
                    let buildTwo = Build(id: 2, jobName: "job name 2", status: "status")
                    expect(buildOne).toNot(equal(buildTwo))
                }
            }
            
            context("When the 'status' property differs for the two Build objects") {
                it("returns false") {
                    let buildOne = Build(id: 2, jobName: "job name", status: "status 1")
                    let buildTwo = Build(id: 2, jobName: "job name", status: "status 2")
                    expect(buildOne).toNot(equal(buildTwo))
                }
            }
        }
    }
}