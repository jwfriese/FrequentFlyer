import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BuildsServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: NSURLRequest?
            var capturedCompletion: ((NSData?, HTTPResponse?, Error?) -> ())?

            override func doRequest(request: NSURLRequest, completion: ((NSData?, HTTPResponse?, Error?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }
        }

        class MockBuildsDataDeserializer: BuildsDataDeserializer {
            var capturedData: NSData?
            var toReturnBuilds: [Build]?
            var toReturnError: DeserializationError?

            override func deserialize(buildsData: NSData) -> (builds: [Build]?, error: DeserializationError?) {
                capturedData = buildsData
                return (toReturnBuilds, toReturnError)
            }
        }

        describe("BuildsService") {
            var subject: BuildsService!
            var mockHTTPClient: MockHTTPClient!
            var mockBuildsDataDeserializer: MockBuildsDataDeserializer!

            beforeEach {
                subject = BuildsService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockBuildsDataDeserializer = MockBuildsDataDeserializer()
                subject.buildsDataDeserializer = mockBuildsDataDeserializer
            }

            describe("Getting a list of builds") {
                var resultBuilds: [Build]?
                var resultError: Error?

                beforeEach {
                    let target = Target(name: "turtle target name",
                        api: "https://turtle_api.com",
                        teamName: "turtle team",
                        token: Token(value: "turtle token"))
                    subject.getBuilds(forTarget: target) { builds, error in
                        resultBuilds = builds
                        resultError = error
                    }
                }

                it("uses its HTTPClient to make the request") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a request with the HTTPClient")
                        return
                    }

                    expect(request.URL?.absoluteString).to(equal("https://turtle_api.com/api/v1/builds"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle token"))
                    expect(request.HTTPMethod).to(equal("GET"))
                }

                describe("When the HTTP request resolves with a success response and valid builds data") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to the HTTPClient")
                            return
                        }

                        let buildOne = Build(id: 2, jobName: "job 2", status: "status 2", pipelineName: "pipeline")
                        let buildTwo = Build(id: 1, jobName: "job 1", status: "status 1", pipelineName: "pipeline")
                        mockBuildsDataDeserializer.toReturnBuilds = [buildOne, buildTwo]

                        let validBuildsData = "valid builds data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(validBuildsData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "valid builds data".dataUsingEncoding(NSUTF8StringEncoding)
                        expect(mockBuildsDataDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("calls the completion handler with the deserialized list of builds") {
                        let expectedBuilds = [
                            Build(id: 2, jobName: "job 2", status: "status 2", pipelineName: "pipeline"),
                            Build(id: 1, jobName: "job 1", status: "status 1", pipelineName: "pipeline")
                        ]

                        expect(resultBuilds).to(equal(expectedBuilds))
                    }

                    it("calls the completion handler with no error") {
                        expect(resultError).to(beNil())
                    }
                }

                describe("When the HTTP request resolves with a success response and deserialization errors") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to the HTTPClient")
                            return
                        }

                        mockBuildsDataDeserializer.toReturnError = DeserializationError(details: "error details", type: .InvalidInputFormat)

                        let invalidBuildsData = "invalid builds data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(invalidBuildsData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "invalid builds data".dataUsingEncoding(NSUTF8StringEncoding)
                        expect(mockBuildsDataDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("calls the completion handler nil list of builds") {
                        expect(resultBuilds).to(beNil())
                    }

                    it("calls the completion handler with the error that comes from the deserializer") {
                        expect(resultError as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .InvalidInputFormat)))
                    }
                }

                describe("When the HTTP request resolves with an error response") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to the HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseImpl(statusCode: 500), BasicError(details: "error details"))
                    }

                    it("calls the completion handler nil list of builds") {
                        expect(resultBuilds).to(beNil())
                    }

                    it("calls the completion handler with the error that came back from the request") {
                        expect(resultError as? BasicError).to(equal(BasicError(details: "error details")))
                    }
                }
            }
        }
    }
}
