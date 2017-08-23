import XCTest
import Quick
import Nimble
import RxSwift
import ObjectMapper

@testable import FrequentFlyer

class InfoDeserializerSpec: QuickSpec {
    override func spec() {
        describe("InfoDeserializer") {
            var subject: InfoDeserializer!

            beforeEach {
                subject = InfoDeserializer()
            }

            describe("Deserializing valid token data") {
                var deserialization$: Observable<Info>!
                var result: StreamResult<Info>!

                context("For data originating as a dictionary") {
                    beforeEach {
                        let validInfoDataDictionary = [
                            "version" : "versionString"
                        ]

                        let validInfoData = try! JSONSerialization.data(withJSONObject: validInfoDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(validInfoData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns a info") {
                        expect(result.elements.first).to(equal(Info(version: "versionString")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Given data originating from a JSON string") {
                    beforeEach {
                        let infoDataString = "{\"version\":\"versionString\"}"
                        let infoData = infoDataString.data(using: String.Encoding.utf8)

                        deserialization$ = subject.deserialize(infoData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns an info initialized with the value") {
                        expect(result.elements.first).to(equal(Info(version: "versionString")))
                    }

                    it("returns nil for the error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Deserializing invalid token data") {
                var deserialization$: Observable<Info>!
                var result: StreamResult<Info>!

                context("Missing 'version' key") {
                    beforeEach {
                        let invalidInfoDataDictionary = ["":""]

                        let invalidInfoData = try! JSONSerialization.data(withJSONObject: invalidInfoDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(invalidInfoData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the token") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.key).to(equal("version"))
                    }
                }

                context("'version' key value is not a string") {
                    beforeEach {
                        let invalidInfoDataDictionary = [
                            "version" : 1
                            ] as [String : Any]

                        let invalidInfoData = try! JSONSerialization.data(withJSONObject: invalidInfoDataDictionary, options: .prettyPrinted)

                        deserialization$ = subject.deserialize(invalidInfoData)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the info") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.key).to(equal("version"))
                    }
                }

                context("Given data cannot be interpreted as a UTF-8 string") {
                    beforeEach {
                        let invalidInfoData = "おはよございます".data(using: String.Encoding.japaneseEUC)

                        deserialization$ = subject.deserialize(invalidInfoData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the info") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("returns an error") {
                        let error = result.error as? MapError
                        expect(error).toNot(beNil())
                        expect(error?.reason).to(equal("Could not interpret response from info endpoint as a UTF-8 string"))
                    }
                }

                context("Given data cannot be interpreted as JSON") {
                    beforeEach {
                        let infoDataString = "some string"

                        let invalidInfoData = infoDataString.data(using: String.Encoding.utf8)

                        deserialization$ = subject.deserialize(invalidInfoData!)
                        result = StreamResult(deserialization$)
                    }

                    it("returns nil for the info") {
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

