import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class InfoServiceSpec: QuickSpec {
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

    class MockInfoDeserializer: InfoDeserializer {
        var capturedData: Data?
        var toReturnInfo: Info?
        var toReturnDeserializationError: Error?

        override func deserialize(_ data: Data) -> Observable<Info> {
            capturedData = data
            if let error = toReturnDeserializationError {
                return Observable.error(error)
            } else {
                return Observable.from(optional: toReturnInfo)
            }
        }
    }

    override func spec() {
        describe("InfoService") {
            var subject: InfoService!
            var mockHTTPClient: MockHTTPClient!
            var mockInfoDeserializer: MockInfoDeserializer!

            beforeEach {
                subject = InfoService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockInfoDeserializer = MockInfoDeserializer()
                subject.infoDeserializer = mockInfoDeserializer
            }

            describe("Fetching info for a Concourse instance") {
                var info$: Observable<Info>!
                var infoStreamResult: StreamResult<Info>!

                beforeEach {
                    info$ = subject.getInfo(forConcourseWithURL: "https://concourse.com")
                    infoStreamResult = StreamResult(info$)
                }

                it("asks the \(HTTPClient.self) to get the Concourse's info") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to use the \(HTTPClient.self) to make a request")
                        return
                    }

                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.url?.absoluteString).to(equal("https://concourse.com/api/v1/info"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    infoStreamResult.disposeBag = DisposeBag()
                    _ = info$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and teams data") {
                    var validInfoResponseData: Data!

                    beforeEach {
                        mockInfoDeserializer.toReturnInfo = Info(version: "1.1.1")

                        validInfoResponseData = "valid teams data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validInfoResponseData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockInfoDeserializer.capturedData).to(equal(validInfoResponseData))
                    }

                    it("emits the teams on the returned stream") {
                        expect(infoStreamResult.elements.first).to(equal(Info(version: "1.1.1")))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    var invalidInfoData: Data!

                    beforeEach {
                        mockInfoDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidInfoData = "valid teams data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidInfoData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockInfoDeserializer.capturedData).to(equal(invalidInfoData))
                    }

                    it("emits the error the deserializer returns") {
                        expect(infoStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error response") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("emits no methods") {
                        expect(infoStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(infoStreamResult.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }
            }
        }
    }
}
