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
                            "type" : "basic",
                            "auth_url": "basic_turtle.com"
                        ],
                        [
                            "type" : "oauth",
                            "auth_url": "oauth_turtle.com"
                        ]
                    ]

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
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

                    expect(authMethods[0]).to(equal(AuthMethod(type: .basic, url: "basic_turtle.com")))
                    expect(authMethods[1]).to(equal(AuthMethod(type: .github, url: "oauth_turtle.com")))
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
                                "type" : "basic",
                                "auth_url": "basic_turtle.com"
                            ],
                            [
                                "somethingelse" : "value",
                                "auth_url": "basic_crab.com"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
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

                        expect(authMethods[0]).to(equal(AuthMethod(type: .basic, url: "basic_turtle.com")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'type' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "type" : "basic",
                                "auth_url": "basic_turtle.com"
                            ],
                            [
                                "type" : 1,
                                "auth_url": "basic_turtle.com"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
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

                        expect(authMethods[0]).to(equal(AuthMethod(type: .basic, url: "basic_turtle.com")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'auth_url' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "type" : "basic",
                            ],
                            [
                                "type" : "oauth",
                                "auth_url": "basic_crab.com"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
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

                        expect(authMethods[0]).to(equal(AuthMethod(type: .github, url: "basic_crab.com")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'auth_url' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "type" : "basic",
                                "auth_url": "basic_turtle.com"
                            ],
                            [
                                "type" : "basic",
                                "auth_url": 1
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
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

                        expect(authMethods[0]).to(equal(AuthMethod(type: .basic, url: "basic_turtle.com")))
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

                    let invalidAuthMethodsData = authMethodsDataString.data(using: String.Encoding.utf8)
                    result = subject.deserialize(invalidAuthMethodsData!)
                }

                it("returns nil for the auth methods") {
                    expect(result.authMethods).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
