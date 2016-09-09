import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class PipelineDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("PipelineDataDeserializer") {
            var subject: PipelineDataDeserializer!

            beforeEach {
                subject = PipelineDataDeserializer()
            }

            describe("Deserializing pipeline data that is all valid") {
                var result: (pipelines: [Pipeline]?, error: DeserializationError?)

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "name" : "turtle pipeline one",
                            "team_name" : "turtle team name"
                        ],
                        [
                            "name" : "turtle pipeline two",
                            "team_name" : "turtle team name"
                        ]
                    ]

                    let validData = try! NSJSONSerialization.dataWithJSONObject(validDataJSONArray, options: .PrettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a pipeline for each JSON pipeline entry") {
                    guard let pipelines = result.pipelines else {
                        fail("Failed to return any pipelines from the JSON data")
                        return
                    }

                    if pipelines.count != 2 {
                        fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                        return
                    }

                    expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one")))
                    expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline two")))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing pipeline data where some of the data is invalid") {
                var result: (pipelines: [Pipeline]?, error: DeserializationError?)

                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "team_name" : "turtle team name"
                            ],
                            [
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.pipelines else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : 1,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.pipelines else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: (pipelines: [Pipeline]?, error: DeserializationError?)

                beforeEach {
                    let pipelinesDataString = "some string"

                    let invalidPipelinesData = pipelinesDataString.dataUsingEncoding(NSUTF8StringEncoding)
                    result = subject.deserialize(invalidPipelinesData!)
                }

                it("returns nil for the pipelines") {
                    expect(result.pipelines).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat)))
                }
            }
        }
    }
}
