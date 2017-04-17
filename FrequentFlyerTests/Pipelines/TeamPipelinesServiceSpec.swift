import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class TeamPipelinesServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: URLRequest?
            var callCount = 0

            var responseSubject = PublishSubject<HTTPResponse>()

            override func perform(request: URLRequest) -> Observable<HTTPResponse> {
                capturedRequest = request
                callCount += 1
                return responseSubject
            }
        }

        class MockPipelineDataDeserializer: PipelineDataDeserializer {
            var capturedData: Data?
            var toReturnPipelines: [Pipeline]?
            var toReturnError: DeserializationError?

            override func deserialize(_ data: Data) -> ([Pipeline]?, DeserializationError?) {
                capturedData = data
                return (toReturnPipelines, toReturnError)
            }
        }

        describe("TeamPipelinesService") {
            var subject: TeamPipelinesService!
            var mockHTTPClient: MockHTTPClient!
            var mockPipelineDataDeserializer: MockPipelineDataDeserializer!

            beforeEach {
                subject = TeamPipelinesService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockPipelineDataDeserializer = MockPipelineDataDeserializer()
                subject.pipelineDataDeserializer = mockPipelineDataDeserializer
            }

            describe("Getting the pipelines for a team") {
                var resultPipelines: [Pipeline]?
                var resultError: Error?

                beforeEach {
                    let target = Target(name: "turtle target name",
                        api: "https://api.com",
                        teamName: "turtle_team_name",
                        token: Token(value: "Bearer turtle auth token")
                    )
                    subject.getPipelines(forTarget: target) { pipelines, error in
                        resultPipelines = pipelines
                        resultError = error
                    }
                }

                it("passes the necessary request to the HTTPClient") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with HTTPClient")
                        return
                    }

                    expect(request.url?.absoluteString).to(equal("https://api.com/api/v1/teams/turtle_team_name/pipelines"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle auth token"))
                    expect(request.httpMethod).to(equal("GET"))
                }

                describe("When the request resolves with a success response and valid pipeline data") {
                    beforeEach {
                        mockPipelineDataDeserializer.toReturnPipelines = [
                            Pipeline(name: "turtle super pipeline")
                        ]

                        let validPipelineData = "valid pipeline data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validPipelineData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        guard let data = mockPipelineDataDeserializer.capturedData else {
                            fail("Failed to pass any data to the PipelineDataDeserializer")
                            return
                        }

                        let expectedData = "valid pipeline data".data(using: String.Encoding.utf8)
                        expect(data).to(equal(expectedData!))
                    }

                    it("calls the completion handler with the deserialized data") {
                        expect(resultPipelines?[0]).to(equal(Pipeline(name: "turtle super pipeline")))
                    }

                    it("calls the completion handler with no error") {
                        expect(resultError).to(beNil())
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    beforeEach {
                        mockPipelineDataDeserializer.toReturnError = DeserializationError(details: "error details", type: .invalidInputFormat)

                        let invalidData = "invalid data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidData, statusCode: 200))
                    }

                    it("calls the completion handler with nil for the pipeline data") {
                        expect(resultPipelines).to(beNil())
                    }

                    it("calls the completion handler with the error that came from the deserializer") {
                        expect(resultError as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with a 401 response") {
                    beforeEach {
                        let unauthorizedData = "not authorized".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: unauthorizedData, statusCode: 401))
                    }

                    it("calls the completion handler with nil for the pipeline data") {
                        expect(resultPipelines).to(beNil())
                    }

                    it("calls the completion handler with an \(AuthorizationError.self)") {
                        expect(resultError as? AuthorizationError).toNot(beNil())
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "error details"))
                    }

                    it("calls the completion handler with nil for the pipeline data") {
                        expect(resultPipelines).to(beNil())
                    }

                    it("calls the completion handler with the error that came from the request") {
                        expect(resultError as? BasicError).to(equal(BasicError(details: "error details")))
                    }
                }
            }
        }
    }
}
