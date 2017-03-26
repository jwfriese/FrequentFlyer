import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class BasicAuthTokenServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: URLRequest?
            var capturedCompletion: ((HTTPResponse?, FFError?) -> ())?
            var callCount = 0

            override func doRequest(_ request: URLRequest, completion: ((HTTPResponse?, FFError?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }

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

            override func deserializeold(_ tokenData: Data) -> (token: Token?, error: DeserializationError?) {
                capturedTokenData = tokenData
                return (toReturnToken, toReturnDeserializationError)
            }

            override func deserialize(_ data: Data) -> ReplaySubject<Token> {
                capturedTokenData = data
                let subject = ReplaySubject<Token>.createUnbounded()
                if let error = toReturnDeserializationError {
                    subject.onError(error)
                } else {
                    if let token = toReturnToken {
                        subject.onNext(token)
                    }
                    subject.onCompleted()
                }
                return subject
            }
        }

        describe("BasicAuthTokenService") {
            var subject: BasicAuthTokenService!
            var mockHTTPClient: MockHTTPClient!
            var mockTokenDataDeserializer: MockTokenDataDeserializer!

            beforeEach {
                subject = BasicAuthTokenService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockTokenDataDeserializer = MockTokenDataDeserializer()
                subject.tokenDataDeserializer = mockTokenDataDeserializer
            }

            describe("Generating the base64 encoded auth header for a super-long username:password glob") {
                beforeEach {
                    let crazyUsername = "561fc0a5-e06a-4bab-ab90-9a9beb55d8bc"
                    let crazyPassword = "4d79db14-2e04-4408-8388-bdc3d0fba25a"
                    let _ = subject.getToken(forTeamWithName: "turtle_team_name", concourseURL: "https://concourse.com", username: crazyUsername, password: crazyPassword)
                }

                it("generates a base64 string from the username:password glob without any newlines") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call to the HTTPClient")
                        return
                    }

                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Basic NTYxZmMwYTUtZTA2YS00YmFiLWFiOTAtOWE5YmViNTVkOGJjOjRkNzlkYjE0LTJlMDQtNDQwOC04Mzg4LWJkYzNkMGZiYTI1YQ=="))
                }
            }

            describe("Fetching a token with basic authentication") {
                var token$: Observable<Token>!
                var tokenStreamResult: StreamResult<Token>!

                beforeEach {
                    token$ = subject.getToken(forTeamWithName: "turtle_team_name", concourseURL: "https://concourse.com", username: "u", password: "p")
                    tokenStreamResult = StreamResult(token$)
                }

                it("makes a call to the HTTP client") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call to the HTTPClient")
                        return
                    }

                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.url?.absoluteString).to(equal("https://concourse.com/api/v1/teams/turtle_team_name/auth/token"))

                    // "dTpw" is the result of base-64 encoding "u:p", the username and password values passed in
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Basic dTpw"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    tokenStreamResult.disposeBag = DisposeBag()
                    _ = token$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
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

                    it("emits the deserialized token") {
                        expect(tokenStreamResult.elements).to(equal([deserializedToken]))
                    }

                    it("does not error") {
                        expect(tokenStreamResult.error).to(beNil())
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

                    it("does not emit a token") {
                        expect(tokenStreamResult.elements).to(beEmpty())
                    }

                    it("emits the error the deserializer returns") {
                        expect(tokenStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the token auth call resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("emits no token") {
                        expect(tokenStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(tokenStreamResult.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }
            }
        }
    }
}
