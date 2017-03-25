import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class AuthMethodDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("AuthMethodDataDeserializer") {
            var subject: AuthMethodDataDeserializer!
            let publishSubject = PublishSubject<AuthMethod>()
            var result: StreamResult<AuthMethod>!
            var authMethods: [AuthMethod] {
                get {
                    return result.elements
                }
            }

            beforeEach {
                subject = AuthMethodDataDeserializer()
            }

            describe("Deserializing auth methods data that is all valid") {

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
                    result = StreamResult(subject.deserialize(validData))
                }

                it("returns an auth method for each JSON auth method entry") {
                    if authMethods.count != 2 {
                        fail("Expected to return 2 auth methods, returned \(authMethods.count)")
                        return
                    }

                    expect(authMethods[0]).to(equal(AuthMethod(type: .basic, url: "basic_turtle.com")))
                    expect(authMethods[1]).to(equal(AuthMethod(type: .gitHub, url: "oauth_turtle.com")))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing auth method data where some of the data is invalid") {

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
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits an auth method for each valid JSON auth method entry") {
                        expect(authMethods).to(equal([AuthMethod(type: .basic, url: "basic_turtle.com")]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
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
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits an auth method for each valid JSON auth method entry") {
                        expect(authMethods).to(equal([AuthMethod(type: .basic, url: "basic_turtle.com")]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
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
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits an auth method for each valid JSON auth method entry") {
                        expect(authMethods).to(equal([AuthMethod(type: .gitHub, url: "basic_crab.com")]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
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
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits an auth method for each valid JSON auth method entry") {
                        expect(authMethods).to(equal([AuthMethod(type: .basic, url: "basic_turtle.com")]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                beforeEach {
                    let authMethodsDataString = "some string"

                    let invalidAuthMethodsData = authMethodsDataString.data(using: String.Encoding.utf8)
                    result = StreamResult(subject.deserialize(invalidAuthMethodsData!))
                }

                it("emits no methods") {
                    expect(authMethods).to(haveCount(0))
                }

                it("emits an error") {
                    expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
