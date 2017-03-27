import XCTest
import Quick
import Nimble
import Fleet
import RxSwift
@testable import FrequentFlyer

class TokenValidationServiceSpec: QuickSpec {
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

                    expect(request.url?.absoluteString).to(equal("turtle_concourse.com/api/v1/containers"))
                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer valid turtle token"))
                }

                describe("When the token is valid") {
                    beforeEach {
                        let doesNotMatterData = Data()
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: doesNotMatterData, statusCode: 200))
                    }

                    it("resolves the original input completion block with no error") {
                        expect(capturedError).to(beNil())
                    }
                }

                describe("When the token is not valid") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "turtle error"))
                    }

                    it("resolves the original input completion block with the error from the network call") {
                        expect(capturedError as? BasicError).to(equal(BasicError(details: "turtle error")))
                    }
                }
            }
        }
    }
}
