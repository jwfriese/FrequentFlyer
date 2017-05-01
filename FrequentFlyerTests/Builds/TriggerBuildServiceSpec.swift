import XCTest
import Quick
import Nimble
import RxSwift
import SwiftyJSON

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

        describe("TriggerBuildService") {
            var subject: TriggerBuildService!
            var mockHTTPClient: MockHTTPClient!
            var mockBuildDataDeserializer: MockBuildDataDeserializer!

            var result: StreamResult<Build>!

            beforeEach {
                subject = TriggerBuildService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockBuildDataDeserializer = MockBuildDataDeserializer()
                subject.buildDataDeserializer = mockBuildDataDeserializer
            }

            describe("Triggering a new build for a job") {
                beforeEach {
                    let target = Target(name: "turtle target",
                                        api: "https://turtles.com",
                                        teamName: "turtle_team",
                                        token: Token(value: "turtle token value")
                    )

                    let build$ = subject.triggerBuild(forTarget: target, forJob: "crab_job", inPipeline: "crab_pipeline")
                    result = StreamResult(build$)
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
                        mockBuildDataDeserializer.toReturnBuild = BuildBuilder().build()

                        let buildData = "build data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: buildData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockBuildDataDeserializer.capturedData).to(equal("build data".data(using: String.Encoding.utf8)))
                    }

                    it("resolves the service's completion handler using the build the deserializer returns") {
                        let expectedBuild = BuildBuilder().build()
                        expect(result.elements.first).to(equal(expectedBuild))
                    }

                    it("resolves the service's completion handler with a nil error") {
                        expect(result.error).to(beNil())
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("resolves the service's completion handler with nil for the build") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("resolves the service's completion handler with the error that the client returned") {
                        expect(result.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }

                describe("When the request resolves with success response and deserialization fails") {
                    var invalidBuildData: Data!

                    beforeEach {
                        mockBuildDataDeserializer.toReturnError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidBuildData = "invalid build data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidBuildData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockBuildDataDeserializer.capturedData).to(equal(invalidBuildData))
                    }

                    it("resolves the service's completion handler with a nil build") {
                        expect(result.elements.first).to(beNil())
                    }

                    it("resolves the service's completion handler with the error the deserializer returns") {
                        expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }
            }
        }
    }
}
