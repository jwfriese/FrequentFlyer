import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TargetFactorySpec: QuickSpec {
    override func spec() {
        describe("TargetFactory") {
            describe("Default behavior") {
                var target: Target!

                beforeEach {
                    target = try! Factory.createTarget()
                }

                it("creates a Target with some default values for all its properties") {
                    expect(target.name).to(equal("turtle name"))
                    expect(target.api).to(equal("https://turtle.com"))
                    expect(target.teamName).to(equal("turtle team"))
                    expect(target.token).to(equal(Token(value: "turtle token")))
                }
            }

            describe("Overriding 'name' property") {
                context("When the overriding value is a string") {
                    var target: Target!

                    beforeEach {
                        target = try! Factory.createTarget(["name" : "crab name" as AnyObject])
                    }

                    it("sets the override value for 'name' property") {
                        expect(target.name).to(equal("crab name"))
                    }

                    it("sets default values for everything else") {
                        expect(target.api).to(equal("https://turtle.com"))
                        expect(target.teamName).to(equal("turtle team"))
                        expect(target.token).to(equal(Token(value: "turtle token")))
                    }
                }

                context("When the overriding value is not a string") {
                    it("throws an error") {
                        expect { try Factory.createTarget(["name" : 1 as AnyObject]) }.to(throwError() { (error: FactoryPropertyTypeError<String>) in
                            expect(error.description).to(equal("Invalid type for property override with name 'name' (expected type='String'"))
                            })
                    }
                }
            }

            describe("Overriding 'api' property") {
                context("When the overriding value is a string") {
                    var target: Target!

                    beforeEach {
                        target = try! Factory.createTarget(["api" : "https://crab.com" as AnyObject])
                    }

                    it("sets the override value for 'api' property") {
                        expect(target.api).to(equal("https://crab.com"))
                    }

                    it("sets default values for everything else") {
                        expect(target.name).to(equal("turtle name"))
                        expect(target.teamName).to(equal("turtle team"))
                        expect(target.token).to(equal(Token(value: "turtle token")))
                    }
                }

                context("When the overriding value is not a string") {
                    it("throws an error") {
                        expect { try Factory.createTarget(["api" : 1 as AnyObject]) }.to(throwError() { (error: FactoryPropertyTypeError<String>) in
                            expect(error.description).to(equal("Invalid type for property override with name 'api' (expected type='String'"))
                            })
                    }
                }
            }

            describe("Overriding 'teamName' property") {
                context("When the overriding value is a string") {
                    var target: Target!

                    beforeEach {
                        target = try! Factory.createTarget(["teamName" : "crab team" as AnyObject])
                    }

                    it("sets the override value for 'teamName' property") {
                        expect(target.teamName).to(equal("crab team"))
                    }

                    it("sets default values for everything else") {
                        expect(target.name).to(equal("turtle name"))
                        expect(target.api).to(equal("https://turtle.com"))
                        expect(target.token).to(equal(Token(value: "turtle token")))
                    }
                }

                context("When the overriding value is not a string") {
                    it("throws an error") {
                        expect { try Factory.createTarget(["teamName" : 1 as AnyObject]) }.to(throwError() { (error: FactoryPropertyTypeError<String>) in
                            expect(error.description).to(equal("Invalid type for property override with name 'teamName' (expected type='String'"))
                            })
                    }
                }
            }

            describe("Overriding 'token' property") {
                context("When the overriding value is a string") {
                    var target: Target!

                    beforeEach {
                        target = try! Factory.createTarget(["token" : "crab token" as AnyObject])
                    }

                    it("sets the override value for 'token' property") {
                        expect(target.token).to(equal(Token(value: "crab token")))
                    }

                    it("sets default values for everything else") {
                        expect(target.name).to(equal("turtle name"))
                        expect(target.api).to(equal("https://turtle.com"))
                        expect(target.teamName).to(equal("turtle team"))
                    }
                }

                context("When the overriding value is not a string") {
                    it("throws an error") {
                        expect { try Factory.createTarget(["token" : 1 as AnyObject]) }.to(throwError() { (error: FactoryPropertyTypeError<String>) in
                            expect(error.description).to(equal("Invalid type for property override with name 'token' (expected type='String'"))
                            })
                    }
                }
            }
        }
    }
}
