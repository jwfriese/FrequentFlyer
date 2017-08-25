import XCTest
import Quick
import Nimble
import RxSwift
import ObjectMapper

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

                    it("emits a token initialized with the value") {
                        expect(result.elements.first).to(equal(Token(value: "token value")))
                    }

                    it("emits no error") {
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
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.key).to(equal("value"))
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
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.key).to(equal("value"))
                    }
                }

                context("Given data cannot be interpreted as a UTF-8 string") {
                    beforeEach {
                        let invalidTokenData = "おはよございます".data(using: String.Encoding.japaneseEUC)

                        deserialization$ = subject.deserialize(invalidTokenData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the token") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.reason).to(equal("Could not interpret response from token endpoint as a UTF-8 string"))
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
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.reason).to(equal("Cannot parse into '[String: Any]'"))
                    }
                }
            }
        }
    }
}
