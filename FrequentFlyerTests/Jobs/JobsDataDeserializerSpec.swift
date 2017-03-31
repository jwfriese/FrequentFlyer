import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class JobsDataDeserializerSpec: QuickSpec {
    class MockBuildDataDeserializer: BuildDataDeserializer {
        var capturedInputList: [Data] = []
        var toReturnBuild: Build?
        var toReturnError: DeserializationError?

        override func deserialize(_ data: Data) -> (build: Build?, error: DeserializationError?) {
            capturedInputList.append(data)
            return (toReturnBuild, toReturnError)
        }
    }

    override func spec() {
        describe("JobsDataDeserializer") {
            var subject: JobsDataDeserializer!
            var mockBuildDataDeserializer: MockBuildDataDeserializer!

            let publishSubject = PublishSubject<[Job]>()
            var result: StreamResult<[Job]>!
            var jobs: [Job] {
                get {
                    return result.elements.flatMap { $0 }
                }
            }

            beforeEach {
                subject = JobsDataDeserializer()

                mockBuildDataDeserializer = MockBuildDataDeserializer()
                subject.buildDataDeserializer = mockBuildDataDeserializer
            }

            describe("Deserializing jobs data that is all valid") {
                let mockBuildOutput = Build(
                    id: 5,
                    name: "name",
                    teamName: "teamName",
                    jobName: "jobName",
                    status: "status",
                    pipelineName: "pipelineName"
                )

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "name" : "turtle job",
                            "finished_build" : [ "turtle_key" : "turtle_value" ]
                        ],
                        [
                            "name" : "crab job",
                            "finished_build" : [ "crab_key" : "crab_value" ]
                        ]
                    ]

                    mockBuildDataDeserializer.toReturnBuild = mockBuildOutput

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
                    result = StreamResult(subject.deserialize(validData))
                }

                it("returns a job for each JSON job entry") {
                    if jobs.count != 2 {
                        fail("Expected to return 2 jobs, returned \(jobs.count)")
                        return
                    }

                    expect(jobs[0]).to(equal(Job(name: "turtle job", builds: [mockBuildOutput])))
                    expect(jobs[1]).to(equal(Job(name: "crab job", builds: [mockBuildOutput])))
                }

                it("used the \(BuildDataDeserializer.self) to deserialize build data") {
                    let expectedDeserializerTurtleInput = try! JSONSerialization.data(withJSONObject: ["turtle_key":"turtle_value"], options: .prettyPrinted)
                    let expectedDeserializerCrabInput = try! JSONSerialization.data(withJSONObject: ["crab_key":"crab_value"], options: .prettyPrinted)
                    expect(mockBuildDataDeserializer.capturedInputList).to(contain(expectedDeserializerTurtleInput))
                    expect(mockBuildDataDeserializer.capturedInputList).to(contain(expectedDeserializerCrabInput))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing job data where some of the data is invalid") {
                let mockBuildOutput = BuildBuilder().withName("build from deserializer").build()

                beforeEach {
                    mockBuildDataDeserializer.toReturnBuild = mockBuildOutput
                }

                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle job",
                                "finished_build" : [ "turtle_key" : "turtle_value" ]
                            ],
                            [
                                "somethingelse" : "value",
                                "finished_build" : [ "turtle_key" : "turtle_value" ]
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "turtle job", builds: [mockBuildOutput])]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle job",
                                "finished_build" : [ "turtle_key" : "turtle_value" ]
                            ],
                            [
                                "name" : 1,
                                "finished_build" : [ "turtle_key" : "turtle_value" ]
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "turtle job", builds: [mockBuildOutput])]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("Missing required 'finished_build' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle job"
                            ],
                            [
                                "name" : "value",
                                "finished_build" : [ "turtle_key" : "turtle_value" ]
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "value", builds: [mockBuildOutput])]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("'finished_build' field is not a dictionary") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle job",
                                "finished_build" : "not a dictionary",
                            ],
                            [
                                "name" : "crab job",
                                "finished_build" : [ "key" : "value" ]
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "crab job", builds: [mockBuildOutput])]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                beforeEach {
                    let jobsDataString = "some string"

                    let invalidJobsData = jobsDataString.data(using: String.Encoding.utf8)
                    result = StreamResult(subject.deserialize(invalidJobsData!))
                }

                it("emits no methods") {
                    expect(jobs).to(haveCount(0))
                }

                it("emits an error") {
                    expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
