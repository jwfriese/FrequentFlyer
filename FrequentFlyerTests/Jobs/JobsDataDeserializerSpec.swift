import XCTest
import Quick
import Nimble
import RxSwift
import SwiftyJSON

@testable import FrequentFlyer

class JobsDataDeserializerSpec: QuickSpec {
    class MockBuildDataDeserializer: BuildDataDeserializer {
        private var toReturnBuild: [Data : Build] = [:]
        private var toReturnError: [Data : DeserializationError] = [:]

        fileprivate func when(_ data: JSON, thenReturn build: Build) {
            let jsonData = try! data.rawData(options: .prettyPrinted)
            toReturnBuild[jsonData] = build
        }

        fileprivate func when(_ data: JSON, thenErrorWith error: DeserializationError) {
            let jsonData = try! data.rawData(options: .prettyPrinted)
            toReturnError[jsonData] = error
        }

        override func deserialize(_ data: Data) -> (build: Build?, error: DeserializationError?) {
            let inputAsJSON = JSON(data: data)

            for (keyData, build) in toReturnBuild {
                let keyAsJSON = JSON(data: keyData)
                if keyAsJSON == inputAsJSON {
                    return (build, nil)
                }
            }

            for (keyData, error) in toReturnError {
                let keyAsJSON = JSON(data: keyData)
                if keyAsJSON == inputAsJSON {
                    return (nil, error)
                }
            }

            return (nil, nil)
        }
    }

    override func spec() {
        describe("JobsDataDeserializer") {
            var subject: JobsDataDeserializer!
            var mockBuildDataDeserializer: MockBuildDataDeserializer!

            var validNextBuildJSONOne: JSON!
            var validFinishedBuildJSONOne: JSON!
            var validNextBuildJSONTwo: JSON!
            var validFinishedBuildJSONTwo: JSON!

            var validFinishedBuildResultOne: Build!
            var validNextBuildResultOne: Build!
            var validFinishedBuildResultTwo: Build!
            var validNextBuildResultTwo: Build!

            var validJobJSONOne: JSON!
            var validJobJSONTwo: JSON!

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

                validFinishedBuildJSONOne = JSON(dictionaryLiteral: [
                    ("name", "finished one")
                ])

                validNextBuildJSONOne = JSON(dictionaryLiteral: [
                    ("name", "next one")
                ])


                validJobJSONOne = JSON(dictionaryLiteral :[
                    ("name", "turtle job"),
                    ("finished_build", validFinishedBuildJSONOne),
                    ("next_build", validNextBuildJSONOne),
                    ("groups", ["group_one", "group_two"])
                ])

                validFinishedBuildJSONTwo = JSON(dictionaryLiteral: [
                    ("name", "finished two"),
                ])

                validNextBuildJSONTwo = JSON(dictionaryLiteral: [
                    ("name", "next two")
                ])

                validJobJSONTwo = JSON(dictionaryLiteral :[
                    ("name", "crab job"),
                    ("finished_build", validFinishedBuildJSONTwo),
                    ("next_build", validNextBuildJSONTwo),
                    ("groups", ["group_one", "group_three"])
                ])

                validFinishedBuildResultOne = BuildBuilder().withName("finished one").build()
                validNextBuildResultOne = BuildBuilder().withName("next one").build()
                validFinishedBuildResultTwo = BuildBuilder().withName("finished two").build()
                validNextBuildResultTwo = BuildBuilder().withName("next two").build()

                mockBuildDataDeserializer.when(validFinishedBuildJSONOne, thenReturn: validFinishedBuildResultOne)
                mockBuildDataDeserializer.when(validFinishedBuildJSONTwo, thenReturn: validFinishedBuildResultTwo)
                mockBuildDataDeserializer.when(validNextBuildJSONOne, thenReturn: validNextBuildResultOne)
                mockBuildDataDeserializer.when(validNextBuildJSONTwo, thenReturn: validNextBuildResultTwo)
            }

            describe("Deserializing jobs data that is all valid") {
                beforeEach {
                    let validInputJSON = JSON([
                        validJobJSONOne,
                        validJobJSONTwo
                    ])

                    let validData = try! validInputJSON.rawData(options: .prettyPrinted)
                    result = StreamResult(subject.deserialize(validData))
                }

                it("returns a job for each JSON job entry") {
                    if jobs.count != 2 {
                        fail("Expected to return 2 jobs, returned \(jobs.count)")
                        return
                    }

                    let expectedJobOne = Job(
                        name: "turtle job",
                        nextBuild: validNextBuildResultOne,
                        finishedBuild: validFinishedBuildResultOne,
                        groups: ["group_one", "group_two"]
                    )

                    let expectedJobTwo = Job(
                        name: "crab job",
                        nextBuild: validNextBuildResultTwo,
                        finishedBuild: validFinishedBuildResultTwo,
                        groups: ["group_one", "group_three"]
                    )

                    expect(jobs[0]).to(equal(expectedJobOne))
                    expect(jobs[1]).to(equal(expectedJobTwo))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing job data where some of the data is invalid") {
                context("Missing required 'name' field") {
                    beforeEach {
                        var invalidJobJSON: JSON! = validJobJSONTwo
                        _ = invalidJobJSON.dictionaryObject?.removeValue(forKey: "name")

                        let inputJSON = JSON([
                            validJobJSONOne,
                            invalidJobJSON
                        ])

                        let invalidData = try! inputJSON.rawData(options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(invalidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        let expectedJob = Job(
                            name: "turtle job",
                            nextBuild: validNextBuildResultOne,
                            finishedBuild: validFinishedBuildResultOne,
                            groups: ["group_one", "group_two"]
                        )
                        expect(jobs).to(equal([expectedJob]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        var invalidJobJSON: JSON! = validJobJSONTwo
                        _ = invalidJobJSON.dictionaryObject?.updateValue(1, forKey: "name")

                        let inputJSON = JSON([
                            validJobJSONOne,
                            invalidJobJSON
                        ])

                        let invalidData = try! inputJSON.rawData(options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(invalidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        let expectedJob = Job(
                            name: "turtle job",
                            nextBuild: validNextBuildResultOne,
                            finishedBuild: validFinishedBuildResultOne,
                            groups: ["group_one", "group_two"]
                        )
                        expect(jobs).to(equal([expectedJob]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("Missing both 'next_build' and 'finished_build' fields simulataneously") {
                    beforeEach {
                        var invalidJobJSON: JSON! = validJobJSONTwo
                        _ = invalidJobJSON.dictionaryObject?.removeValue(forKey: "next_build")
                        _ = invalidJobJSON.dictionaryObject?.removeValue(forKey: "finished_build")

                        let inputJSON = JSON([
                            validJobJSONOne,
                            invalidJobJSON
                        ])

                        let invalidData = try! inputJSON.rawData(options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(invalidData))
                    }

                    it("emits a job only for each valid JSON job entry") {
                        let expectedJob = Job(
                            name: "turtle job",
                            nextBuild: validNextBuildResultOne,
                            finishedBuild: validFinishedBuildResultOne,
                            groups: ["group_one", "group_two"]
                        )
                        expect(jobs).to(equal([expectedJob]))
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
