import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TargetSpec: QuickSpec {
    override func spec() {
        describe("Equality operator") {
            context("When all properties of the Target objects are equal") {
                let targetOne = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                let targetTwo = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                
                it("returns true") {
                    expect(targetOne).to(equal(targetTwo))
                }
            }
            
            context("When name property values of the Target objects are different") {
                let targetOne = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                let targetTwo = Target(name: "turtle foot name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                
                it("returns false") {
                    expect(targetOne).toNot(equal(targetTwo))
                }
            }
            
            context("When api property values of the Target objects are different") {
                let targetOne = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                let targetTwo = Target(name: "turtle shell name", api: "some other api", teamName: "turtle team", token: Token(value: "value"))
                
                it("returns false") {
                    expect(targetOne).toNot(equal(targetTwo))
                }
            }
            
            context("When teamName property values of the Target objects are different") {
                let targetOne = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                let targetTwo = Target(name: "turtle shell name", api: "turtle api", teamName: "some other team", token: Token(value: "value"))
                
                it("returns false") {
                    expect(targetOne).toNot(equal(targetTwo))
                }
            }
            
            context("When token property values of the Target objects are different") {
                let targetOne = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "value"))
                let targetTwo = Target(name: "turtle shell name", api: "turtle api", teamName: "turtle team", token: Token(value: "some other value"))
                
                it("returns false") {
                    expect(targetOne).toNot(equal(targetTwo))
                }
            }
        }
    }
}