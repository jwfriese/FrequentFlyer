import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class BuildsServiceSpec: QuickSpec {
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

        class MockBuildsDataDeserializer: BuildsDataDeserializer {
            var capturedData: Data?
            var toReturnBuilds: [Build]?
            var toReturnError: DeserializationError?

            override func deserialize(_ buildsData: Data) -> (builds: [Build]?, error: DeserializationError?) {
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

                    expect(request.url?.absoluteString).to(equal("https://turtle_api.com/api/v1/builds"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle token"))
                    expect(request.httpMethod).to(equal("GET"))
                }

                describe("When the HTTP request resolves with a success response and valid builds data") {
                    beforeEach {
                        let buildOne = BuildBuilder().withName("turtle build").build()
                        let buildTwo = BuildBuilder().withName("crab build").build()
                        mockBuildsDataDeserializer.toReturnBuilds = [buildOne, buildTwo]

                        let validBuildsData = "valid builds data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validBuildsData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "valid builds data".data(using: String.Encoding.utf8)
                        expect(mockBuildsDataDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("calls the completion handler with the deserialized list of builds") {
                        let expectedBuilds = [
                            BuildBuilder().withName("turtle build").build(),
                            BuildBuilder().withName("crab build").build()
                        ]

                        expect(resultBuilds).to(equal(expectedBuilds))
                    }

                    it("calls the completion handler with no error") {
                        expect(resultError).to(beNil())
                    }
                }

                describe("When the HTTP request resolves with a success response and deserialization errors") {
                    beforeEach {
                        mockBuildsDataDeserializer.toReturnError = DeserializationError(details: "error details", type: .invalidInputFormat)

                        let invalidBuildsData = "invalid builds data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidBuildsData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "invalid builds data".data(using: String.Encoding.utf8)
                        expect(mockBuildsDataDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("calls the completion handler nil list of builds") {
                        expect(resultBuilds).to(beNil())
                    }

                    it("calls the completion handler with the error that comes from the deserializer") {
                        expect(resultError as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the HTTP request resolves with an error response") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "error details"))
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
