import XCTest
import Quick
import Nimble
import RxSwift
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
                var deserialization$: Observable<[Pipeline]>!
                var result: StreamResult<[Pipeline]>!

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
                    deserialization$ = subject.deserialize(validData)
                    result = StreamResult(deserialization$)
                }

                it("emits a pipeline for each JSON pipeline entry") {
                    expect(result.elements.first?.count).to(equal(2))
                    expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                    expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline two", isPublic: true, teamName: "turtle team name")))
                }

                it("emits no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing pipeline data where some of the data is invalid") {
                var deserialization$: Observable<[Pipeline]>!
                var result: StreamResult<[Pipeline]>!

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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("emits no error") {
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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("emits no error") {
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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: false, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: true, teamName: "turtle team name")))
                    }

                    it("emits no error") {
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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("emits no error") {
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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: false, teamName: "turtle team name")))
                    }

                    it("emits no error") {
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
                        deserialization$ = subject.deserialize(partiallyValidData)
                        result = StreamResult(deserialization$)
                    }

                    it("emits a pipeline for each valid JSON pipeline entry") {
                        expect(result.elements.first?.count).to(equal(2))
                        expect(result.elements.first?[0]).to(equal(Pipeline(name: "turtle pipeline one", isPublic: true, teamName: "turtle team name")))
                        expect(result.elements.first?[1]).to(equal(Pipeline(name: "turtle pipeline three", isPublic: true, teamName: "turtle team name")))
                    }

                    it("emits no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var deserialization$: Observable<[Pipeline]>!
                var result: StreamResult<[Pipeline]>!

                beforeEach {
                    let pipelinesDataString = "some string"

                    let invalidPipelinesData = pipelinesDataString.data(using: String.Encoding.utf8)
                    deserialization$ = subject.deserialize(invalidPipelinesData!)
                    result = StreamResult(deserialization$)
                }

                it("emits no pipelines") {
                    expect(result.elements).to(beEmpty())
                }

                it("emits an error") {
                    let error = result.error as? MapError
                    expect(error).toNot(beNil())
                    expect(error?.reason).to(equal("Could not interpret data as JSON"))
                }
            }
        }
    }
}
