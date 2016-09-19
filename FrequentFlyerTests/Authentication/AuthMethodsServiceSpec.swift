import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class AuthMethodsServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: NSURLRequest?
            var capturedCompletion: ((NSData?, HTTPResponse?, Error?) -> ())?

            override func doRequest(request: NSURLRequest, completion: ((NSData?, HTTPResponse?, Error?) -> ())?) {
                capturedRequest = request
                capturedCompletion = completion
            }
        }

        class MockAuthMethodDataDeserializer: AuthMethodDataDeserializer {
            var capturedData: NSData?
            var toReturnAuthMethods: [AuthMethod]?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(data: NSData) -> (authMethods: [AuthMethod]?, error: DeserializationError?) {
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
                var capturedError: Error?

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
                    expect(request.HTTPMethod).to(equal("GET"))
                    expect(request.URL?.absoluteString).to(equal("https://concourse.com/api/v1/teams/turtle_team_name/auth/methods"))
                }

                describe("When the request resolves with a success response and auth method data") {
                    var validAuthMethodResponseData: NSData!
                    var deserializedAuthMethods: [AuthMethod]!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        deserializedAuthMethods = [AuthMethod(type: .Basic, url: ".com")]
                        mockAuthMethodDataDeserializer.toReturnAuthMethods = deserializedAuthMethods

                        validAuthMethodResponseData = "valid auth method data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(validAuthMethodResponseData, HTTPResponseImpl(statusCode: 200), nil)
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
                    var invalidAuthMethodData: NSData!

                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        mockAuthMethodDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .InvalidInputFormat)

                        invalidAuthMethodData = "valid auth method data".dataUsingEncoding(NSUTF8StringEncoding)
                        completion(invalidAuthMethodData, HTTPResponseImpl(statusCode: 200), nil)
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

                        expect(capturedError as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .InvalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error response") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseImpl(statusCode: 200), BasicError(details: "some error string"))
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
