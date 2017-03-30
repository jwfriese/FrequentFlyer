import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class JobsDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("JobsDataDeserializer") {
            var subject: JobsDataDeserializer!
            let publishSubject = PublishSubject<[Job]>()
            var result: StreamResult<[Job]>!
            var jobs: [Job] {
                get {
                    return result.elements.flatMap { $0 }
                }
            }

            beforeEach {
                subject = JobsDataDeserializer()
            }

            describe("Deserializing jobs data that is all valid") {

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "name" : "turtle job"
                        ],
                        [
                            "name" : "crab job"
                        ]
                    ]

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
                    result = StreamResult(subject.deserialize(validData))
                }

                it("returns a job for each JSON job entry") {
                    if jobs.count != 2 {
                        fail("Expected to return 2 jobs, returned \(jobs.count)")
                        return
                    }

                    expect(jobs[0]).to(equal(Job(name: "turtle job", builds: [])))
                    expect(jobs[1]).to(equal(Job(name: "crab job", builds: [])))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing job data where some of the data is invalid") {
                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "turtle job"
                            ],
                            [
                                "somethingelse" : "value"
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "turtle job", builds: [])]))
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
                            ],
                            [
                                "name" : 1
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        expect(jobs).to(equal([Job(name: "turtle job", builds: [])]))
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
