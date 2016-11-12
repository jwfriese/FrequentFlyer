import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TriggerBuildServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: URLRequest?
            var capturedCompletion: ((Data?, HTTPResponse?, FFError?) -> ())?

            override func doRequest(_ request: URLRequest, completion: ((Data?, HTTPResponse?, FFError?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }
        }

        class MockBuildDataDeserializer: BuildDataDeserializer {
            var capturedData: Data?
            var toReturnBuild: Build?
            var toReturnError: DeserializationError?

            override func deserialize(_ data: Data) -> (build: Build?, error: DeserializationError?) {
                capturedData = data
                return (toReturnBuild, toReturnError)
            }
        }

        describe("TriggerBuildService") {
            var subject: TriggerBuildService!
            var mockHTTPClient: MockHTTPClient!
            var mockBuildDataDeserializer: MockBuildDataDeserializer!

            beforeEach {
                subject = TriggerBuildService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockBuildDataDeserializer = MockBuildDataDeserializer()
                subject.buildDataDeserializer = mockBuildDataDeserializer
            }

            describe("Triggering a new build for a job") {
                var capturedBuild: Build?
                var capturedError: FFError?

                beforeEach {
                    let target = Target(name: "turtle target",
                        api: "https://turtles.com",
                        teamName: "turtle_team",
                        token: Token(value: "turtle token value")
                    )

                    subject.triggerBuild(forTarget: target, forJob: "crab_job", inPipeline: "crab_pipeline") { build, error in
                        capturedBuild = build
                        capturedError = error
                    }
                }

                it("makes a request through the HTTPClient") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with the HTTPClient")
                        return
                    }

                    expect(request.httpMethod).to(equal("POST"))
                    expect(request.url?.absoluteString).to(equal("https://turtles.com/api/v1/teams/turtle_team/pipelines/crab_pipeline/jobs/crab_job/builds"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle token value"))
                }

                describe("When the request resolves with a success response and data for a build that is triggered") {

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass a completion handler to the HTTPClient")
                            return
                        }

                        mockBuildDataDeserializer.toReturnBuild = Build(id: 124,
                            jobName: "turtle job",
                            status: "turtle status",
                            pipelineName: "turtle pipeline")

                        let buildData = "build data".data(using: String.Encoding.utf8)
                        completion(buildData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockBuildDataDeserializer.capturedData).to(equal("build data".data(using: String.Encoding.utf8)))
                    }

                    it("resolves the service's completion handler using the build the deserializer returns") {
                        let expectedBuild = Build(id: 124,
                                                  jobName: "turtle job",
                                                  status: "turtle status",
                                                  pipelineName: "turtle pipeline")
                        expect(capturedBuild).to(equal(expectedBuild))
                    }

                    it("resolves the service's completion handler with a nil error") {
                        expect(capturedError).to(beNil())
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseImpl(statusCode: 200), BasicError(details: "some error string"))
                    }

                    it("resolves the service's completion handler with nil for the build") {
                        expect(capturedBuild).to(beNil())
                    }

                    it("resolves the service's completion handler with the error that the client returned") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }

                describe("When the request resolves with success response and deserialization fails") {
                    var invalidBuildData: Data!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        mockBuildDataDeserializer.toReturnError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidBuildData = "invalid build data".data(using: String.Encoding.utf8)
                        completion(invalidBuildData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockBuildDataDeserializer.capturedData).to(equal(invalidBuildData))
                    }

                    it("resolves the service's completion handler with a nil build") {
                        expect(capturedBuild).to(beNil())
                    }

                    it("resolves the service's completion handler with the error the deserializer returns") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }
            }
        }
    }
}
