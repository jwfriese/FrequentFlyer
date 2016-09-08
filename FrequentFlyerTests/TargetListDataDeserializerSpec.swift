import XCTest
import Quick
import Nimble
import SwiftCoreExtensions
@testable import FrequentFlyer

class TargetListDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("TargetListDataDeserializer") {
            var subject: TargetListDataDeserializer!
            
            beforeEach {
                subject = TargetListDataDeserializer()
            }
            
            describe("Deserializing target list data") {
                var result: (targetList: [Target]?, error: DeserializationError?)
                let validTargetsDictionary = [
                    "targets": [
                        [
                            "name": "turtle feet target",
                            "api": "https://example.com",
                            "team": "turtle feet team",
                            "token": [
                                "type": "turtle bearer",
                                "value": "turtle feet token value"
                            ]
                        ],
                        [
                            "name": "turtle head target",
                            "api": "https://example2.com",
                            "team": "turtle head team",
                            "token": [
                                "type": "turtle bearer",
                                "value": "turtle head token value"
                            ]
                        ]
                    ]
                ]
                
                context("When asked to deserialize valid data") {
                    beforeEach {
                        let validTargetsData = NSKeyedArchiver.archivedDataWithRootObject(validTargetsDictionary)
                        result = subject.deserialize(validTargetsData)
                    }
                    
                    it("returns no error in the result") {
                        expect(result.error).to(beNil())
                    }
                    
                    it("returns a list of all the targets deserialized") {
                        guard let targetList = result.targetList else {
                            fail("No target list deserialized")
                            return
                        }
                        
                        expect(targetList.count).to(equal(2))
                        
                        let expectedTargetOne = Target(name: "turtle feet target", api: "https://example.com",
                                                       teamName: "turtle feet team", token: Token(value: "turtle feet token value")
                        )
                        expect(targetList[0]).to(equal(expectedTargetOne))
                        
                        let expectedTargetTwo = Target(name: "turtle head target", api: "https://example2.com",
                                                       teamName: "turtle head team", token: Token(value: "turtle head token value")
                        )
                        expect(targetList[1]).to(equal(expectedTargetTwo))
                    }
                }
                
                context("Error cases") {
                    context("When missing top level 'targets' item") {
                        beforeEach {
                            let invalidTargetsDictionary = validTargetsDictionary.without("targets")
                            let invalidTargetsDictionaryData = NSKeyedArchiver.archivedDataWithRootObject(invalidTargetsDictionary)
                            result = subject.deserialize(invalidTargetsDictionaryData)
                        }
                        
                        it("returns nil for the target list") {
                            expect(result.targetList).to(beNil())
                        }
                        
                        it("returns an error") {
                            guard let error = result.error else {
                                fail("No error returned from failed deserialization")
                                return
                            }
                            
                            expect(error.type).to(equal(DeserializationErrorType.MissingRequiredData))
                            expect(error.details).to(equal("Missing required 'targets' key"))
                        }
                    }
                    
                    context("When given data that cannot be interpreted as JSON") {
                        beforeEach {
                            let nonJSONData = "some string".dataUsingEncoding(NSUTF8StringEncoding)
                            result = subject.deserialize(nonJSONData!)
                        }
                        
                        it("returns nil for the target list") {
                            expect(result.targetList).to(beNil())
                        }
                        
                        it("returns an error") {
                            guard let error = result.error else {
                                fail("No error returned from failed deserialization")
                                return
                            }
                            
                            expect(error.type).to(equal(DeserializationErrorType.InvalidInputFormat))
                            expect(error.details).to(equal("Input data must be interpretable as JSON"))
                        }
                    }
                    
                    context("When one of the targets does not have complete data") {
                        beforeEach {
                            let withIncompleteTargetDictionary = validTargetsDictionary.without("targets:0:team")
                            let withIncompleteTargetDictionaryData = NSKeyedArchiver.archivedDataWithRootObject(withIncompleteTargetDictionary)
                            result = subject.deserialize(withIncompleteTargetDictionaryData)
                        }
                        
                        it("returns a target list containing a target for all complete data items") {
                            guard let targetList = result.targetList else {
                                fail("No target list deserialized")
                                return
                            }
                            
                            expect(targetList.count).to(equal(1))
                            let expectedTarget = Target(name: "turtle head target", api: "https://example2.com", teamName: "turtle head team", token: Token(value: "turtle head token value")
                            )
                            expect(targetList[0]).to(equal(expectedTarget))
                        }
                        
                        it("returns no error") {
                            expect(result.error).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
