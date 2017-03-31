import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BuildsDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("BuildsDataDeserializer") {
            var subject: BuildsDataDeserializer!

            beforeEach {
                subject = BuildsDataDeserializer()
            }

            describe("Deserializing builds data that is all valid") {
                var result: (builds: [Build]?, error: DeserializationError?)

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "id" : 2,
                            "name": "name",
                            "team_name": "team name",
                            "status" : "status 2",
                            "job_name" : "turtle job name",
                            "pipeline_name" : "turtle pipeline name"
                        ],
                        [
                            "id" : 1,
                            "name": "name",
                            "team_name": "team name",
                            "status" : "status 1",
                            "job_name" : "crab job name",
                            "pipeline_name" : "crab pipeline name"
                        ]
                    ]

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a build for each JSON build entry") {
                    guard let builds = result.builds else {
                        fail("Failed to return any builds from the JSON data")
                        return
                    }

                    if builds.count != 2 {
                        fail("Expected to return 2 builds, returned \(builds.count)")
                        return
                    }

                    let expectedBuildOne = Build(id: 2, name: "name", teamName:"team name", jobName: "turtle job name", status: "status 2", pipelineName: "turtle pipeline name")
                    let expectedBuildTwo = Build(id: 1, name: "name", teamName:"team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")

                    expect(builds[0]).to(equal(expectedBuildOne))
                    expect(builds[1]).to(equal(expectedBuildTwo))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing build data where some of the data is invalid") {
                var result: (builds: [Build]?, error: DeserializationError?)

                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": 100,
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'team_name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'team_name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": 100,
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'status' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'status' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : 100,
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'job_name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "pipeline_name" : "turtle pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'job_name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : 1000,
                                "pipeline_name" : "turtle pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job name", status: "status", pipelineName: "turtle pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'id' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'id' field is not an int") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : "id value",
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : "turtle pipeline name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("Missing required 'pipeline_name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }

                context("'pipeline_name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status",
                                "job_name" : "turtle job name",
                                "pipeline_name" : 1
                            ],
                            [
                                "id" : 2,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "crab status",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ],
                            [
                                "id" : 1,
                                "name": "name",
                                "team_name": "team name",
                                "status" : "status 1",
                                "job_name" : "crab job name",
                                "pipeline_name" : "crab pipeline name"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }

                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }

                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }

                        expect(builds[0]).to(equal(Build(id: 2, name: "name", teamName: "team name", jobName: "crab job name", status: "crab status", pipelineName: "crab pipeline name")))
                        expect(builds[1]).to(equal(Build(id: 1, name: "name", teamName: "team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")))
                    }

                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: (builds: [Build]?, error: DeserializationError?)

                beforeEach {
                    let buildsDataString = "some string"

                    let invalidbuildsData = buildsDataString.data(using: String.Encoding.utf8)
                    result = subject.deserialize(invalidbuildsData!)
                }

                it("returns nil for the builds") {
                    expect(result.builds).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
