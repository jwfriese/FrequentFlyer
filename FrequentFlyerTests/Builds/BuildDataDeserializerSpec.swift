import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BuildDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("BuildDataDeserializer") {
            var subject: BuildDataDeserializer!

            beforeEach {
                subject = BuildDataDeserializer()
            }

            describe("Deserializing build data that is all valid") {
                var result: (build: Build?, error: DeserializationError?)

                beforeEach {
                    let validDataJSONArray = [
                        "id" : 2,
                        "status" : "status 2",
                        "job_name" : "turtle job name",
                        "pipeline_name" : "turtle pipeline name"

                    ]

                    let validData = try! NSJSONSerialization.dataWithJSONObject(validDataJSONArray, options: .PrettyPrinted)
                    result = subject.deserialize(validData)
                }

                it("returns a build for each JSON build entry") {
                    expect(result.build).to(equal(Build(id: 2, jobName: "turtle job name", status: "status 2", pipelineName: "turtle pipeline name")))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing build data where the data is invalid") {
                var result: (build: Build?, error: DeserializationError?)

                context("Missing required 'status' field") {
                    beforeEach {
                        let invalidDataJSON = [
                            "id" : 2,
                            "job_name" : "turtle job name",
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidData = try! NSJSONSerialization.dataWithJSONObject(invalidDataJSON, options: .PrettyPrinted)
                        result = subject.deserialize(invalidData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'status' field", type: .MissingRequiredData)))
                    }
                }

                context("'status' field is not a string") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : 2,
                            "status" : 100,
                            "job_name" : "turtle job name",
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'status' field to be a string", type: .TypeMismatch)))
                    }
                }

                context("Missing required 'job_name' field") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : 1,
                            "status" : "status 1",
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'job_name' field", type: .MissingRequiredData)))
                    }
                }

                context("'job_name' field is not a string") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : 1,
                            "status" : "status 1",
                            "job_name" : 1000,
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'job_name' field to be a string", type: .TypeMismatch)))
                    }
                }

                context("Missing required 'id' field") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "status" : "status",
                            "job_name" : "turtle job name",
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'id' field", type: .MissingRequiredData)))
                    }
                }

                context("'id' field is not an int") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : "id value",
                            "status" : "status",
                            "job_name" : "turtle job name",
                            "pipeline_name" : "turtle pipeline name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'id' field to be an integer", type: .TypeMismatch)))
                    }
                }

                context("Missing required 'pipeline_name' field") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : 3,
                            "status" : "status",
                            "job_name" : "turtle job name"
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Missing required 'pipeline_name' field", type: .MissingRequiredData)))
                    }
                }

                context("'pipeline_name' field is not a string") {
                    beforeEach {
                        let invalidJSONDictionary = [
                            "id" : 3,
                            "status" : "status",
                            "job_name" : "turtle job name",
                            "pipeline_name" : 1
                        ]

                        let invalidJSONData = try! NSJSONSerialization.dataWithJSONObject(invalidJSONDictionary, options: .PrettyPrinted)
                        result = subject.deserialize(invalidJSONData)
                    }

                    it("returns nil for the build") {
                        expect(result.build).to(beNil())
                    }

                    it("returns an error") {
                        expect(result.error).to(equal(DeserializationError(details: "Expected value for 'pipeline_name' field to be a string", type: .TypeMismatch)))
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                var result: (build: Build?, error: DeserializationError?)

                beforeEach {
                    let buildDataString = "some string"

                    let invalidbuildData = buildDataString.dataUsingEncoding(NSUTF8StringEncoding)
                    result = subject.deserialize(invalidbuildData!)
                }

                it("returns nil for the build") {
                    expect(result.build).to(beNil())
                }

                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat)))
                }
            }
        }
    }
}
