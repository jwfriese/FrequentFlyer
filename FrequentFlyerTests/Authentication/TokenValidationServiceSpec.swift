import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class TokenValidationServiceSpec: QuickSpec {
    class MockHTTPClient: HTTPClient {
        var capturedRequest: NSURLRequest?
        var capturedCompletion: ((NSData?, HTTPResponse?, Error?) -> ())?

        override func doRequest(request: NSURLRequest, completion: ((NSData?, HTTPResponse?, Error?) -> ())?) {
            capturedRequest = request
            capturedCompletion = completion
        }
    }

    override func spec() {
        describe("TokenValidationService") {
            var subject: TokenValidationService!
            var mockHTTPClient: MockHTTPClient!

            beforeEach {
                subject = TokenValidationService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient
            }

            describe("Validating a token") {
                var capturedError: Error?

                beforeEach {
                    let token = Token(value: "valid turtle token")

                    subject.validate(token: token, forConcourse: "turtle_concourse.com") { error in
                        capturedError = error
                    }
                }

                it("uses the HTTPClient to make a request") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call to the HTTPClient")
                        return
                    }

                    expect(request.URL?.absoluteString).to(equal("turtle_concourse.com/api/v1/containers"))
                    expect(request.HTTPMethod).to(equal("GET"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer valid turtle token"))
                }

                describe("When the token is valid") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass a completion handler to the HTTPClient")
                            return
                        }

                        // Set error to something not nil to ensure that the prod code actually calls
                        // the completion handler with nil.
                        capturedError = BasicError(details: "error")

                        let doesNotMatterData = NSData()
                        completion(doesNotMatterData, HTTPResponseImpl(statusCode: 200), nil)
                    }

                    it("resolves the original input completion block with no error") {
                        expect(capturedError).to(beNil())
                    }
                }

                describe("When the token is not valid") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass a completion handler to the HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseImpl(statusCode: 401), BasicError(details: "turtle error"))
                    }

                    it("resolves the original input completion block with the error from the network call") {
                        expect(capturedError as? BasicError).to(equal(BasicError(details: "turtle error")))
                    }
                }
            }
        }
    }
}
