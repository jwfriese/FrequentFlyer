import XCTest
import Quick
import Nimble
import SwiftyJSON

@testable import FrequentFlyer

class BuildDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("BuildDataDeserializer") {
            var subject: BuildDataDeserializer!

            var validBuildJSON: JSON!

            beforeEach {
                subject = BuildDataDeserializer()

                validBuildJSON = JSON(dictionaryLiteral: [
                    ("id", 2),
                    ("name", "turtle build name"),
                    ("team_name", "turtle team name"),
                    ("status", "status 2"),
                    ("job_name", "turtle job name"),
                    ("pipeline_name", "turtle pipeline name")
                ])
            }

            describe("Deserializing build data that is all valid") {
                var result: (build: Build?, error: DeserializationError?)

                beforeEach {
                    let validData = try! validBuildJSON.rawData(options: .prettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a build for each JSON build entry") {
                    let expectedBuild = Build(
                        id: 2,
                        name: "turtle build name",
                        teamName: "turtle team name",
                        jobName: "turtle job name",
                        status: "status 2",
                        pipelineName: "turtle pipeline name"
                    )

                    expect(result.build).to(equal(expectedBuild))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing build data where the data is invalid") {
                var result: (build: Build?, error: DeserializationError?)

                context("Missing required 'name' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'name' field", type: .missingRequiredData)))
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue(10, forKey: "name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'name' field to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'team_name' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "team_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'team_name' field", type: .missingRequiredData)))
                    }
                }

                context("'team_name' field is not a string") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue(10, forKey: "team_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'team_name' field to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'status' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "status")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'status' field", type: .missingRequiredData)))
                    }
                }

                context("'status' field is not a string") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue(10, forKey: "status")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'status' field to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'job_name' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "job_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'job_name' field", type: .missingRequiredData)))
                    }
                }

                context("'job_name' field is not a string") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue(10, forKey: "job_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'job_name' field to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'id' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "id")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'id' field", type: .missingRequiredData)))
                    }
                }

                context("'id' field is not an int") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue("value", forKey: "id")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'id' field to be an integer", type: .typeMismatch)))
                    }
                }

                context("Missing required 'pipeline_name' field") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.removeValue(forKey: "pipeline_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'pipeline_name' field", type: .missingRequiredData)))
                    }
                }

                context("'pipeline_name' field is not a string") {
                    beforeEach {
                        var invalidBuildJSON: JSON! = validBuildJSON
                        _ = invalidBuildJSON.dictionaryObject?.updateValue(10, forKey: "pipeline_name")

                        let invalidData = try! invalidBuildJSON.rawData(options: .prettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'pipeline_name' field to be a string", type: .typeMismatch)))
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: (build: Build?, error: DeserializationError?)

                beforeEach {
                    let buildDataString = "some string"

                    let invalidbuildData = buildDataString.data(using: String.Encoding.utf8)
                    result = subject.deserialize(invalidbuildData!)
                }

                it("returns nil for the build") {
                    expect(result.build).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
