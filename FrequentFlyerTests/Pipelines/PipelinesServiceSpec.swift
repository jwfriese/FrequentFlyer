import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer
import Result

class PipelinesServiceSpec: QuickSpec {
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
            var capturedPipelineData: Data?
            var toReturnPipelines: [Pipeline]?
            var toReturnError: Error?

            override func deserialize(_ data: Data) -> Observable<[Pipeline]> {
                capturedPipelineData = data
                if let error = toReturnError {
                    return Observable.error(error)
                } else {
                    return Observable.from(optional: toReturnPipelines)
                }
            }
        }

        describe("PipelinesService") {
            var subject: PipelinesService!
            var mockHTTPClient: MockHTTPClient!
            var mockPipelineDataDeserializer: MockPipelineDataDeserializer!

            beforeEach {
                subject = PipelinesService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockPipelineDataDeserializer = MockPipelineDataDeserializer()
                subject.pipelineDataDeserializer = mockPipelineDataDeserializer
            }

            describe("Getting the pipelines for a team") {
                var pipeline$: Observable<[Pipeline]>!
                var pipeline$Result: StreamResult<[Pipeline]>!

                beforeEach {
                    let target = Target(name: "turtle target name",
                        api: "https://api.com",
                        teamName: "turtle_team_name",
                        token: Token(value: "Bearer turtle auth token")
                    )

                    pipeline$ = subject.getPipelines(forTarget: target)
                    pipeline$Result = StreamResult(pipeline$)
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
                            Pipeline(name: "turtle super pipeline", isPublic: false, teamName: "")
                        ]

                        let validPipelineData = "valid pipeline data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validPipelineData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        guard let data = mockPipelineDataDeserializer.capturedPipelineData else {
                            fail("Failed to pass any data to the PipelineDataDeserializer")
                            return
                        }

                        let expectedData = "valid pipeline data".data(using: String.Encoding.utf8)
                        expect(data).to(equal(expectedData!))
                    }

                    it("emits the deserialized data") {
                        expect(pipeline$Result.elements.first?.first).to(equal(Pipeline(name: "turtle super pipeline", isPublic: false, teamName: "")))
                    }

                    it("emits no error") {
                        expect(pipeline$Result.error).to(beNil())
                    }
                }

                describe("When the request resolves with a success response and deserialization fails with an error") {
                    var error: TestError!

                    beforeEach {
                        error = TestError()
                        mockPipelineDataDeserializer.toReturnError = error

                        let invalidData = "invalid data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidData, statusCode: 200))
                    }

                    it("emits no pipelines") {
                        expect(pipeline$Result.elements).to(beEmpty())
                    }

                    it("emits the error that came from the deserializer") {
                        expect(pipeline$Result.error as? TestError).to(equal(error))
                    }
                }

                describe("When the request resolves with no body") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: nil, statusCode: 500))
                    }

                    it("emits nil for the pipeline data") {
                        expect(pipeline$Result.elements.first).to(beNil())
                    }

                    it("emits an \(UnexpectedError.self)") {
                        expect(pipeline$Result.error as? UnexpectedError).toNot(beNil())
                    }
                }

                describe("When the request resolves with a 401 response") {
                    beforeEach {
                        let unauthorizedData = "not authorized".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: unauthorizedData, statusCode: 401))
                    }

                    it("emits no pipelines") {
                        expect(pipeline$Result.elements).to(beEmpty())
                    }

                    it("emits an \(AuthorizationError.self)") {
                        expect(pipeline$Result.error as? AuthorizationError).toNot(beNil())
                    }
                }

                describe("When the request resolves with an error") {
                    var error: TestError!

                    beforeEach {
                        error = TestError()
                        mockHTTPClient.responseSubject.onError(error)
                    }

                    it("emits no pipelines") {
                        expect(pipeline$Result.elements).to(beEmpty())
                    }

                    it("emits the error that came from the request") {
                        expect(pipeline$Result.error as? TestError).to(equal(error))
                    }
                }
            }
        }
    }
}
