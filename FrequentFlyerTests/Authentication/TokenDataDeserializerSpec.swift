import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TokenDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("TokenDataDeserializer") {
            var subject: TokenDataDeserializer!

            beforeEach {
                subject = TokenDataDeserializer()
            }

            describe("Deserializing valid token data") {
                var result: (token: Token?, error: DeserializationError?)

                context("For data originating as a dictionary") {
                    beforeEach {
                        let validTokenDataDictionary = [
                            "type" : "token type",
                            "value" : "token value"
                        ]

                        let validTokenData = try! NSJSONSerialization.dataWithJSONObject(validTokenDataDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(validTokenData)
                    }

                    it("returns a token initialized with the value") {
                        expect(result.token).to(equal(Token(value: "token value")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Given data originating from a JSON string") {
                    beforeEach {
                        let tokenDataString = "{\"type\":\"token type\",\"value\":\"token value\"}"
                        let tokenData = tokenDataString.dataUsingEncoding(NSUTF8StringEncoding)

                        result = subject.deserialize(tokenData!)
                    }

                    it("returns a token initialized with the value") {
                        expect(result.token).to(equal(Token(value: "token value")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Deserializing invalid token data") {
                var result: (token: Token?, error: DeserializationError?)

                context("Missing 'value' key") {
                    beforeEach {
                        let invalidTokenDataDictionary = [
                            "type" : "token type"
                        ]

                        let invalidTokenData = try! NSJSONSerialization.dataWithJSONObject(invalidTokenDataDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidTokenData)
                    }

                    it("returns nil for the token") {
                        expect(result.token).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'value' key", type: .MissingRequiredData)))
                    }
                }

                context("'value' key value is not a string") {
                    beforeEach {
                        let invalidTokenDataDictionary = [
                            "type" : "token type",
                            "value" : 1
                        ]

                        let invalidTokenData = try! NSJSONSerialization.dataWithJSONObject(invalidTokenDataDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidTokenData)
                    }

                    it("returns nil for the token") {
                        expect(result.token).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'value' key to be a string", type: .TypeMismatch)))
                    }
                }

                context("Given data cannot be interpreted as JSON") {
                    beforeEach {
                        let tokenDataString = "some string"

                        let invalidTokenData = tokenDataString.dataUsingEncoding(NSUTF8StringEncoding)
                        result = subject.deserialize(invalidTokenData!)
                    }

                    it("returns nil for the token") {
                        expect(result.token).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat)))
                    }
                }
            }
        }
    }
}