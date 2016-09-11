import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("AuthMethodDataDeserializer") {
            var subject: AuthMethodDataDeserializer!

            beforeEach {
                subject = AuthMethodDataDeserializer()
            }

            describe("Deserializing auth methods data that is all valid") {
                var result: (authMethods: [AuthMethod]?, error: DeserializationError?)

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "type" : "basic"
                        ],
                        [
                            "type" : "basic"
                        ]
                    ]

                    let validData = try! NSJSONSerialization.dataWithJSONObject(validDataJSONArray, options: .PrettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns an auth method for each JSON auth method entry") {
                    guard let authMethods = result.authMethods else {
                        fail("Failed to return any auth methods from the JSON data")
                        return
                    }

                    if authMethods.count != 2 {
                        fail("Expected to return 2 auth methods, returned \(authMethods.count)")
                        return
                    }

                    expect(authMethods[0]).to(equal(AuthMethod(type: .Basic)))
                    expect(authMethods[1]).to(equal(AuthMethod(type: .Basic)))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing auth method data where some of the data is invalid") {
                var result: (authMethods: [AuthMethod]?, error: DeserializationError?)

                context("Missing required 'type' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "type" : "basic"
                            ],
                            [
                                "somethingelse" : "value"
                            ]
                        ]

                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns an auth method for each valid JSON auth method entry") {
                        guard let authMethods = result.authMethods else {
                            fail("Failed to return any auth methods from the JSON data")
                            return
                        }

                        if authMethods.count != 1 {
                            fail("Expected to return 1 auth method, returned \(authMethods.count)")
                            return
                        }

                        expect(authMethods[0]).to(equal(AuthMethod(type: .Basic)))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'type' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "type" : "basic"
                            ],
                            [
                                "type" : 1
                            ]
                        ]

                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a auth method for each valid JSON auth method entry") {
                        guard let authMethods = result.authMethods else {
                            fail("Failed to return any auth methods from the JSON data")
                            return
                        }

                        if authMethods.count != 1 {
                            fail("Expected to return 1 auth method, returned \(authMethods.count)")
                            return
                        }

                        expect(authMethods[0]).to(equal(AuthMethod(type: .Basic)))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: (authMethods: [AuthMethod]?, error: DeserializationError?)

                beforeEach {
                    let authMethodsDataString = "some string"

                    let invalidAuthMethodsData = authMethodsDataString.dataUsingEncoding(NSUTF8StringEncoding)
                    result = subject.deserialize(invalidAuthMethodsData!)
                }

                it("returns nil for the auth methods") {
                    expect(result.authMethods).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat)))
                }
            }
        }
    }
}
