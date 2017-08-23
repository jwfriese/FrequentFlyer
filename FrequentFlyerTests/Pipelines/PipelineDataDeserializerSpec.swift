import XCTest
import Quick
import Nimble
import Result
import ObjectMapper

@testable import FrequentFlyer

class PipelineDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("PipelineDataDeserializer") {
            var subject: PipelineDataDeserializer!

            beforeEach {
                subject = PipelineDataDeserializer()
            }

            describe("Deserializing pipeline data that is all valid") {
                var result: Result<[Pipeline], AnyError>!

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "name" : "turtle pipeline one",
                            "public" : true,
                            "team_name" : "turtle team name"
                        ],
                        [
                            "name" : "turtle pipeline two",
                            "public" : true,
                            "team_name" : "turtle team name"
                        ]
                    ]

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a pipeline for each JSON pipeline entry") {
                    guard let pipelines = result.value else {
                        fail("Failed to return any pipelines from the JSON data")
                        return
                    }

                    if pipelines.count != 2 {
                        fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                        return
                    }

                    expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                    expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline two", isPublic: true, teamName: "turtle team name")))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing pipeline data where some of the data is invalid") {
                var result: Result<[Pipeline], AnyError>!

                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : false,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
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
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : 1,
                                "public" : false,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : false,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'public' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "public" : false,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : "turtle pipeline two",
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: false, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: true, teamName: "turtle team name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'public' field is not a bool") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : "turtle pipeline two",
                                "public" : 1,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : false,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'team_name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : "turtle pipeline two",
                                "public" : true
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : false,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'team_name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle pipeline one",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ],
                            [
                                "name" : "turtle pipeline two",
                                "public" : true,
                                "team_name" : 1
                            ],
                            [
                                "name": "turtle pipeline three",
                                "public" : true,
                                "team_name" : "turtle team name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a pipeline for each valid JSON pipeline entry") {
                        guard let pipelines = result.value else {
                            fail("Failed to return any pipelines from the JSON data")
                            return
                        }

                        if pipelines.count != 2 {
                            fail("Expected to return 2 pipelines, returned \(pipelines.count)")
                            return
                        }

                        expect(pipelines[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(pipelines[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: true, teamName: "turtle team name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: Result<[Pipeline], AnyError>!

                beforeEach {
                    let pipelinesDataString = "some string"

                    let invalidPipelinesData = pipelinesDataString.data(using: String.Encoding.utf8)
                    result = subject.deserialize(invalidPipelinesData!)
                }

                it("returns nil for the pipelines") {
                    expect(result.value).to(beNil())
                }

                it("returns an error") {
                    let error = result.error?.error as? MapError
                    expect(error).toNot(beNil())
                    expect(error?.reason).to(equal("Could not interpret data as JSON"))
                }
            }
        }
    }
}
