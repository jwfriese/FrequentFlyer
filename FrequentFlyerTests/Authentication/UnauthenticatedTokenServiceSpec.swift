import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class UnauthenticatedTokenServiceSpec: QuickSpec {
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

        class MockTokenDataDeserializer: TokenDataDeserializer {
            var capturedTokenData: Data?
            var toReturnToken: Token?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(_ data: Data) -> Observable<Token> {
                capturedTokenData = data
                if let error = toReturnDeserializationError {
                    return Observable.error(error)
                } else if let token = toReturnToken {
                    return Observable.just(token)
                } else {
                    return Observable.empty()
                }
            }
        }

        describe("UnauthenticatedTokenService") {
            var subject: UnauthenticatedTokenService!
            var mockHTTPClient: MockHTTPClient!
            var mockTokenDataDeserializer: MockTokenDataDeserializer!

            beforeEach {
                subject = UnauthenticatedTokenService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockTokenDataDeserializer = MockTokenDataDeserializer()
                subject.tokenDataDeserializer = mockTokenDataDeserializer
            }

            describe("Fetching a token with no authentication") {
                var token$: Observable<Token>!
                var token$Result: StreamResult<Token>!

                beforeEach {
                    token$ = subject.getUnauthenticatedToken(forTeamName: "turtle_team_name", concourseURL: "https://concourse.com")
                    token$Result = StreamResult(token$)
                }

                it("makes a call to the HTTP client") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call to the HTTPClient")
                        return
                    }

                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.url?.absoluteString).to(equal("https://concourse.com/api/v1/teams/turtle_team_name/auth/token"))
                }

                describe("When the token auth call resolves with success response and valid data") {
                    var validTokenResponseData: Data!
                    var deserializedToken: Token!

                    beforeEach {
                        deserializedToken = Token(value: "turtle auth token")
                        mockTokenDataDeserializer.toReturnToken = deserializedToken

                        validTokenResponseData = "valid token data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validTokenResponseData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTokenDataDeserializer.capturedTokenData).to(equal(validTokenResponseData))
                    }

                    it("resolves the service's completion handler using the token the deserializer returns") {
                        expect(token$Result.elements.first).to(equal(deserializedToken))
                    }

                    it("resolves the service's completion handler with a nil error") {
                        expect(token$Result.error).to(beNil())
                    }
                }

                describe("When the token auth call resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("resolves the service's completion handler with nil for the token") {
                        expect(token$Result.elements.first).to(beNil())
                    }

                    it("resolves the service's completion handler with the error that the client returned") {
                        expect(token$Result.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }

                describe("When the token auth call resolves with success response and deserialization fails") {
                    var invalidTokenDataResponse: Data!

                    beforeEach {
                        mockTokenDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidTokenDataResponse = "valid token data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidTokenDataResponse, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTokenDataDeserializer.capturedTokenData).to(equal(invalidTokenDataResponse))
                    }

                    it("resolves the service's completion handler with a nil token") {
                        expect(token$Result.elements.first).to(beNil())
                    }

                    it("resolves the service's completion handler with the error the deserializer returns") {
                        expect(token$Result.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }
            }
        }
    }
}
