import XCTest
import Quick
import Nimble
import SwiftyJSON

@testable import FrequentFlyer

class BuildsDataDeserializerSpec: QuickSpec {
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
        describe("BuildsDataDeserializer") {
            var subject: BuildsDataDeserializer!
            var mockBuildDataDeserializer: MockBuildDataDeserializer!

            var validBuildJSONOne: JSON!
            var validBuildJSONTwo: JSON!
            var validBuildJSONThree: JSON!
            var result: (builds: [Build]?, error: DeserializationError?)

            beforeEach {
                subject = BuildsDataDeserializer()

                mockBuildDataDeserializer = MockBuildDataDeserializer()
                subject.buildDataDeserializer = mockBuildDataDeserializer

                validBuildJSONOne = JSON(dictionaryLiteral: [
                    ("id", 1),
                    ("name", "name"),
                    ("team_name", "team name"),
                    ("status", "status 1"),
                    ("job_name", "crab job name"),
                    ("pipeline_name", "crab pipeline name")
                ])

                validBuildJSONTwo = JSON(dictionaryLiteral: [
                    ("id", 2),
                    ("name", "name"),
                    ("team_name", "team name"),
                    ("status", "status 2"),
                    ("job_name", "turtle job name"),
                    ("pipeline_name", "turtle pipeline name")
                ])

                validBuildJSONThree = JSON(dictionaryLiteral: [
                    ("id", 3),
                    ("name", "name"),
                    ("team_name", "team name"),
                    ("status", "status 3"),
                    ("job_name", "puppy job name"),
                    ("pipeline_name", "puppy pipeline name")
                ])
            }

            describe("Deserializing builds data where all individual builds are valid") {
                let expectedBuildOne = Build(id: 1, name: "name", teamName:"team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")
                let expectedBuildTwo = Build(id: 2, name: "name", teamName:"team name", jobName: "turtle job name", status: "status 2", pipelineName: "turtle pipeline name")
                let expectedBuildThree = Build(id: 2, name: "name", teamName: "team name", jobName: "puppy job name", status: "status 3", pipelineName: "puppy pipeline name")

                beforeEach {
                    let validBuildsJSON = JSON([
                        validBuildJSONOne,
                        validBuildJSONTwo,
                        validBuildJSONThree
                    ])

                    mockBuildDataDeserializer.when(validBuildJSONOne, thenReturn: expectedBuildOne)
                    mockBuildDataDeserializer.when(validBuildJSONTwo, thenReturn: expectedBuildTwo)
                    mockBuildDataDeserializer.when(validBuildJSONThree, thenReturn: expectedBuildThree)

                    let validData = try! validBuildsJSON.rawData(options: .prettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a build for each JSON build entry") {
                    guard let builds = result.builds else {
                        fail("Failed to return any builds from the JSON data")
                        return
                    }

                    if builds.count != 3 {
                        fail("Expected to return 3 builds, returned \(builds.count)")
                        return
                    }

                    expect(builds[0]).to(equal(expectedBuildOne))
                    expect(builds[1]).to(equal(expectedBuildTwo))
                    expect(builds[2]).to(equal(expectedBuildThree))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing builds data where one of the builds errors") {
                let expectedBuildOne = Build(id: 1, name: "name", teamName:"team name", jobName: "crab job name", status: "status 1", pipelineName: "crab pipeline name")
                let expectedBuildTwo = Build(id: 3, name: "name", teamName: "team name", jobName: "puppy job name", status: "status 3", pipelineName: "puppy pipeline name")

                beforeEach {
                    let validBuildsJSON = JSON([
                        validBuildJSONOne,
                        validBuildJSONTwo,
                        validBuildJSONThree
                    ])

                    mockBuildDataDeserializer.when(validBuildJSONOne, thenReturn: expectedBuildOne)
                    mockBuildDataDeserializer.when(validBuildJSONTwo, thenErrorWith: DeserializationError(details: "error", type: .missingRequiredData))
                    mockBuildDataDeserializer.when(validBuildJSONThree, thenReturn: expectedBuildTwo)

                    let validData = try! validBuildsJSON.rawData(options: .prettyPrinted)
                    result = subject.deserialize(validData)
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

                    expect(builds[0]).to(equal(expectedBuildOne))
                    expect(builds[1]).to(equal(expectedBuildTwo))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
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
