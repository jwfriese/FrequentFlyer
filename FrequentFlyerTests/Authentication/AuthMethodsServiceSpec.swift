import XCTest
import Quick
import Nimble
import RxSwift
import RxTest

@testable import FrequentFlyer

class AuthMethodsServiceSpec: QuickSpec {
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

        class MockAuthMethodDataDeserializer: AuthMethodDataDeserializer {
            var capturedData: Data?
            var toReturnAuthMethods: [AuthMethod]?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(_ data: Data) -> Observable<AuthMethod> {
                capturedData = data
                let subject = ReplaySubject<AuthMethod>.createUnbounded()
                if let error = toReturnDeserializationError {
                    subject.onError(error)
                } else {
                    if let authMethods = toReturnAuthMethods {
                        authMethods.forEach { subject.onNext($0) }
                    }
                    subject.onCompleted()
                }
                return subject
            }
        }

        describe("AuthMethodsService") {
            var subject: AuthMethodsService!
            var mockHTTPClient: MockHTTPClient!
            var mockAuthMethodDataDeserializer: MockAuthMethodDataDeserializer!

            beforeEach {
                subject = AuthMethodsService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockAuthMethodDataDeserializer = MockAuthMethodDataDeserializer()
                subject.authMethodsDataDeserializer = mockAuthMethodDataDeserializer
            }

            describe("Fetching auth methods for a target") {
                var method$: Observable<AuthMethod>!
                var methodStreamResult: StreamResult<AuthMethod>!

                beforeEach {
                    method$ = subject.getMethods(forTeamName: "turtle_team_name", concourseURL: "https://concourse.com")
                    methodStreamResult = StreamResult(method$)
                }

                it("asks the HTTPClient to get the team's auth methods") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to use the HTTPClient to make a request")
                        return
                    }

                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.url?.absoluteString).to(equal("https://concourse.com/api/v1/teams/turtle_team_name/auth/methods"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    methodStreamResult.disposeBag = DisposeBag()
                    _ = method$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and auth method data") {
                    var validAuthMethodResponseData: Data!
                    var deserializedAuthMethods: [AuthMethod]!

                    beforeEach {
                        deserializedAuthMethods = [AuthMethod(type: .basic, url: ".com")]
                        mockAuthMethodDataDeserializer.toReturnAuthMethods = deserializedAuthMethods

                        validAuthMethodResponseData = "valid auth method data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validAuthMethodResponseData, statusCode: 200))

                    }

                    it("passes the data to the deserializer") {
                        expect(mockAuthMethodDataDeserializer.capturedData).to(equal(validAuthMethodResponseData))
                    }

                    it("emits the auth methods on the returned stream") {
                        expect(methodStreamResult.elements).to(equal(deserializedAuthMethods))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    var invalidAuthMethodData: Data!

                    beforeEach {
                        mockAuthMethodDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidAuthMethodData = "valid auth method data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidAuthMethodData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockAuthMethodDataDeserializer.capturedData).to(equal(invalidAuthMethodData))
                    }

                    it("emits the error the deserializer returns") {
                        expect(methodStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error response") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("emits no methods") {
                        expect(methodStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(methodStreamResult.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }
            }
        }
    }
}
