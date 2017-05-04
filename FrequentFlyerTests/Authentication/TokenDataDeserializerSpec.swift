import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class TokenDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("TokenDataDeserializer") {
            var subject: TokenDataDeserializer!

            beforeEach {
                subject = TokenDataDeserializer()
            }

            describe("Deserializing valid token data") {
                var deserialization$: Observable<Token>!
                var result: StreamResult<Token>!

                context("For data originating as a dictionary") {
                    beforeEach {
                        let validTokenDataDictionary = [
                            "type" : "token type",
                            "value" : "token value"
                        ]

                        let validTokenData = try! JSONSerialization.data(withJSONObject: validTokenDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(validTokenData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns a token initialized with the value") {
                        expect(result.elements.first).to(equal(Token(value: "token value")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Given data originating from a JSON string") {
                    beforeEach {
                        let tokenDataString = "{\"type\":\"token type\",\"value\":\"token value\"}"
                        let tokenData = tokenDataString.data(using: String.Encoding.utf8)

                        deserialization$ = subject.deserialize(tokenData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns a token initialized with the value") {
                        expect(result.elements.first).to(equal(Token(value: "token value")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Deserializing invalid token data") {
                var deserialization$: Observable<Token>!
                var result: StreamResult<Token>!

                context("Missing 'value' key") {
                    beforeEach {
                        let invalidTokenDataDictionary = [
                            "type" : "token type"
                        ]

                        let invalidTokenData = try! JSONSerialization.data(withJSONObject: invalidTokenDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(invalidTokenData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the token") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Missing required 'value' key", type: .missingRequiredData)))
                    }
                }

                context("'value' key value is not a string") {
                    beforeEach {
                        let invalidTokenDataDictionary = [
                            "type" : "token type",
                            "value" : 1
                        ] as [String : Any]

                        let invalidTokenData = try! JSONSerialization.data(withJSONObject: invalidTokenDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(invalidTokenData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the token") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Expected value for 'value' key to be a string", type: .typeMismatch)))
                    }
                }

                context("Given data cannot be interpreted as JSON") {
                    beforeEach {
                        let tokenDataString = "some string"

                        let invalidTokenData = tokenDataString.data(using: String.Encoding.utf8)

                        deserialization$ = subject.deserialize(invalidTokenData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the token") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                    }
                }
            }
        }
    }
}
