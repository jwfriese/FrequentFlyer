import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer
import Result

class PublicPipelinesServiceSpec: QuickSpec {
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

        describe("PublicPipelinesService") {
            var subject: PublicPipelinesService!
            var mockHTTPClient: MockHTTPClient!
            var mockPipelineDataDeserializer: MockPipelineDataDeserializer!

            beforeEach {
                subject = PublicPipelinesService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockPipelineDataDeserializer = MockPipelineDataDeserializer()
                subject.pipelineDataDeserializer = mockPipelineDataDeserializer
            }

            describe("Getting the public pipelines for a Concourse instance") {
                var pipeline$: Observable<[Pipeline]>!
                var pipeline$Result: StreamResult<[Pipeline]>!

                beforeEach {
                    pipeline$ = subject.getPipelines(forConcourseWithURL: "https://api.com")
                    pipeline$Result = StreamResult(pipeline$)
                }

                it("passes the necessary request to the HTTPClient") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with HTTPClient")
                        return
                    }

                    expect(request.url?.absoluteString).to(equal("https://api.com/api/v1/pipelines"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.httpMethod).to(equal("GET"))
                }

                describe("When the request resolves with a success response and valid pipeline data") {
                    beforeEach {
                        mockPipelineDataDeserializer.toReturnPipelines = [
                            Pipeline(name: "public pipeline", isPublic: true, teamName: "team name"),
                            Pipeline(name: "public pipeline for another team", isPublic: true, teamName: "some other team")
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

                    it("emits all the returned public pipelines") {
                        let expectedPipelines = [
                            Pipeline(name: "public pipeline", isPublic: true, teamName: "team name"),
                            Pipeline(name: "public pipeline for another team", isPublic: true, teamName: "some other team")
                        ]
                        expect(pipeline$Result.elements.count).to(equal(1))
                        expect(pipeline$Result.elements[0]).to(equal(expectedPipelines))
                    }

                    it("calls the completion handler with no error") {
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

                    it("emits no pipelines") {
                        expect(pipeline$Result.elements).to(beEmpty())
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

                    it("calls the completion handler with the error that came from the request") {
                        expect(pipeline$Result.error as? TestError).to(equal(error))
                    }
                }
            }
        }
    }
}

