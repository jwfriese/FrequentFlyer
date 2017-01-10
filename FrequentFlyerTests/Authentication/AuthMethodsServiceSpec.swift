import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodsServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: URLRequest?
            var capturedCompletion: ((HTTPResponse?, FFError?) -> ())?

            override func doRequest(_ request: URLRequest, completion: ((HTTPResponse?, FFError?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }
        }

        class MockAuthMethodDataDeserializer: AuthMethodDataDeserializer {
            var capturedData: Data?
            var toReturnAuthMethods: [AuthMethod]?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(_ data: Data) -> (authMethods: [AuthMethod]?, error: DeserializationError?) {
                capturedData = data
                return (toReturnAuthMethods, toReturnDeserializationError)
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
                var capturedAuthMethods: [AuthMethod]?
                var capturedError: FFError?

                beforeEach {
                    subject.getMethods(forTeamName: "turtle_team_name", concourseURL: "https://concourse.com") { authMethods, error in
                        capturedAuthMethods = authMethods
                        capturedError = error
                    }
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

                describe("When the request resolves with a success response and auth method data") {
                    var validAuthMethodResponseData: Data!
                    var deserializedAuthMethods: [AuthMethod]!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        deserializedAuthMethods = [AuthMethod(type: .basic, url: ".com")]
                        mockAuthMethodDataDeserializer.toReturnAuthMethods = deserializedAuthMethods

                        validAuthMethodResponseData = "valid auth method data".data(using: String.Encoding.utf8)
                        completion(HTTPResponseImpl(body: validAuthMethodResponseData, statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockAuthMethodDataDeserializer.capturedData).to(equal(validAuthMethodResponseData))
                    }

                    it("resolves the service's completion handler using the auth methods the deserializer returns") {
                        expect(capturedAuthMethods).to(equal(deserializedAuthMethods))
                    }

                    it("resolves the service's completion handler with a nil error") {
                        expect(capturedError).to(beNil())
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    var invalidAuthMethodData: Data!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        mockAuthMethodDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidAuthMethodData = "valid auth method data".data(using: String.Encoding.utf8)
                        completion(HTTPResponseImpl(body: invalidAuthMethodData, statusCode: 200), nil)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockAuthMethodDataDeserializer.capturedData).to(equal(invalidAuthMethodData))
                    }

                    it("resolves the service's completion handler with a nil auth method") {
                        expect(capturedAuthMethods).to(beNil())
                    }

                    it("resolves the service's completion handler with the error the deserializer returns") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error response") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        completion(HTTPResponseImpl(body: nil, statusCode: 200), BasicError(details: "some error string"))
                    }

                    it("resolves the service's completion handler with nil for the auth method") {
                        expect(capturedAuthMethods).to(beNil())
                    }

                    it("resolves the service's completion handler with the error that the client returned") {
                        guard let capturedError = capturedError else {
                            fail("Failed to call completion handler with an error")
                            return
                        }

                        expect(capturedError as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }
            }
        }
    }
}
