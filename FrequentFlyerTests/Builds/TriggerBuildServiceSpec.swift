import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class TriggerBuildServiceSpec: QuickSpec {
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

        class MockBuildDataDeserializer: BuildDataDeserializer {
            var capturedData: Data?
            var toReturnBuild: Build?
            var toReturnError: DeserializationError?

            override func deserialize(_ data: Data) -> (build: Build?, error: DeserializationError?) {
                capturedData = data
                return (toReturnBuild, toReturnError)
            }
        }

        fdescribe("TriggerBuildService") {
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
                var build$: Observable<Build>!
                var buildStreamResult: StreamResult<Build>!

                beforeEach {
                    let target = Target(name: "turtle target",
                                        api: "https://turtles.com",
                                        teamName: "turtle_team",
                                        token: Token(value: "turtle token value")
                    )

                    build$ = subject.triggerBuild(forTarget: target, forJob: "crab_job", inPipeline: "crab_pipeline")
                    buildStreamResult = StreamResult(build$)
                }

                it("makes a request through the \(HTTPClient.self)") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with the \(HTTPClient.self)")
                        return
                    }

                    expect(request.httpMethod).to(equal("POST"))
                    expect(request.url?.absoluteString).to(equal("https://turtles.com/api/v1/teams/turtle_team/pipelines/crab_pipeline/jobs/crab_job/builds"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle token value"))
                }
                
                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    buildStreamResult.disposeBag = DisposeBag()
                    _ = build$.subscribe()
                    
                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and data for a build that is triggered") {
                    beforeEach {
                        mockBuildDataDeserializer.toReturnBuild = BuildBuilder().withName("result build").build()

                        let buildData = "build data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: buildData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        let expectedData = "build data".data(using: String.Encoding.utf8)
                        expect(mockBuildDataDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("emits the build produced by the deserializer") {
                        let expectedBuild = BuildBuilder().withName("result build").build()
                        
                        expect(buildStreamResult.elements.count).to(equal(1))
                        expect(buildStreamResult.elements[0]).to(equal(expectedBuild))
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }
                    
                    it("emits no build") {
                        expect(buildStreamResult.elements).to(haveCount(0))
                    }
                    
                    it("emits the error that the client returned") {
                        expect(buildStreamResult.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }

                describe("When the request resolves with success response and deserialization fails") {
                    beforeEach {
                        mockBuildDataDeserializer.toReturnError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        let invalidBuildData = "invalid build data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidBuildData, statusCode: 200))
                    }
                    
                    it("calls the completion handler with the error that came from the deserializer") {
                        expect(buildStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }
                
                describe("When the request resolves with a 401 response") {
                    beforeEach {
                        let unauthorizedData = "not authorized".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: unauthorizedData, statusCode: 401))
                    }
                    
                    it("emits no build") {
                        expect(buildStreamResult.elements).to(haveCount(0))
                    }
                    
                    it("emits an \(AuthorizationError.self)") {
                        expect(buildStreamResult.error as? AuthorizationError).toNot(beNil())
                    }
                }

            }
        }
    }
}
