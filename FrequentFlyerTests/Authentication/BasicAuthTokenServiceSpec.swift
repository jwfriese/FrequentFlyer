import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BasicAuthTokenServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: NSURLRequest?
            var capturedCompletion: ((NSData?, HTTPResponse?, Error?) -> ())?

            override func doRequest(request: NSURLRequest, completion: ((NSData?, HTTPResponse?, Error?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }
        }

        class MockTokenDataDeserializer: TokenDataDeserializer {
            var capturedTokenData: NSData?
            var toReturnToken: Token?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(tokenData: NSData) -> (token: Token?, error: DeserializationError?) {
                capturedTokenData = tokenData
                return (toReturnToken, toReturnDeserializationError)
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

            describe("Fetching a token with basic authentication") {
                var capturedToken: Token?
                var capturedError: Error?

                beforeEach {
                    subject.getToken(forTeamWithName: "turtle_team_name", concourseURL: "https://concourse.com", username: "u", password: "p") { token, error in
                        capturedToken = token
                        capturedError = error
                    }
                }

                it("makes a call to the HTTP client") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call to the HTTPClient")
                        return
                    }

                    expect(request.HTTPMethod).to(equal("GET"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.URL?.absoluteString).to(equal("https://concourse.com/api/v1/teams/turtle_team_name/auth/token"))

                    // "dTpw" is the result of base-64 encoding "u:p", the username and password values passed in
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Basic dTpw"))
                }

                describe("When the token auth call resolves with success response and valid data") {
                    var validTokenResponseData: NSData!
                    var deserializedToken: Token!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        deserializedToken = Token(value: "turtle auth token")
                        mockTokenDataDeserializer.toReturnToken = deserializedToken

                        validTokenResponseData = "valid token data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(validTokenResponseData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTokenDataDeserializer.capturedTokenData).to(equal(validTokenResponseData))
                    }

                    it("resolves the service's completion handler using the token the deserializer returns") {
                        expect(capturedToken).to(equal(deserializedToken))
                    }

                    it("resolves the service's completion handler with a nil error") {
                        expect(capturedError).to(beNil())
                    }
                }

                describe("When the token auth call resolves with an error") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseImpl(statusCode: 200), BasicError(details: "some error string"))
                    }

                    it("resolves the service's completion handler with nil for the token") {
                        expect(capturedToken).to(beNil())
                    }

                    it("resolves the service's completion handler with the error that the client returned") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }

                describe("When the token auth call resolves with success response and deserialization fails") {
                    var invalidTokenDataResponse: NSData!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        mockTokenDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .InvalidInputFormat)

                        invalidTokenDataResponse = "valid token data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(invalidTokenDataResponse, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTokenDataDeserializer.capturedTokenData).to(equal(invalidTokenDataResponse))
                    }

                    it("resolves the service's completion handler with a nil token") {
                        expect(capturedToken).to(beNil())
                    }

                    it("resolves the service's completion handler with the error the deserializer returns") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .InvalidInputFormat)))
                    }
                }
            }
        }
    }
}
