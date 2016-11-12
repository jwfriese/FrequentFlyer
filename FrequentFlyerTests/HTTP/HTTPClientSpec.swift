import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class HTTPClientSpec: QuickSpec {
    override func spec() {
        describe("HTTPClient") {
            var subject: HTTPClient!

            beforeEach {
                subject = HTTPClient()
            }

            describe("Performing a request") {
                context("When the request returns with a success response") {
                    var capturedData: Data?
                    var capturedResponse: HTTPResponse?
                    var capturedError: FFError?

                    beforeEach {
                        // Set capturedError to some garbage value up front to ensure that the handler gets passed nil
                        capturedError = BasicError(details: "test error")

                        let request = NSMutableURLRequest(url: NSURL(string: "http://localhost:8181/successyeah")! as URL)
                        subject.doRequest(request as URLRequest) { data, response, error in
                            capturedData = data
                            capturedResponse = response
                            capturedError = error
                        }
                    }

                    it("calls the completion handler with the response data") {
                        let testServerData = "{\"success\" : \"yeah\" }".data(using: String.Encoding.utf8)
                        expect(capturedData).toEventually(equal(testServerData))
                    }

                    it("calls the completion handler with the response") {
                        expect(capturedResponse).toEventuallyNot(beNil())
                        expect(capturedResponse?.statusCode).toEventually(equal(200))
                    }

                    it("calls the completion handler with a nil error") {
                        expect(capturedError).toEventually(beNil())
                    }
                }

                context("When the request returns with an error-type response") {
                    var capturedData: Data?
                    var capturedResponse: HTTPResponse?
                    var capturedError: FFError?

                    beforeEach {
                        // Set capturedData to some garbage value up front to ensure that the handler gets passed nil
                        capturedData = Data()

                        let request = NSMutableURLRequest(url: NSURL(string: "http://localhost:8181/errorplease")! as URL)
                        subject.doRequest(request as URLRequest) { data, response, error in
                            capturedData = data
                            capturedResponse = response
                            capturedError = error
                        }
                    }

                    it("calls the completion handler with nil response data") {
                        expect(capturedData).toEventually(beNil())
                    }

                    it("calls the completion handler with the response") {
                        expect(capturedResponse).toEventuallyNot(beNil())
                        expect(capturedResponse?.statusCode).toEventually(equal(500))
                    }

                    it("calls the completion handler with an error that has the data as the details") {
                        expect(capturedError).toEventuallyNot(beNil())
                        expect(capturedError?.details).toEventually(equal("{\"error\" : \"here it is\"}"))
                    }
                }

                context("When the request completely bombs") {
                    var capturedData: Data?
                    var capturedResponse: HTTPResponse?
                    var capturedError: FFError?

                    beforeEach {
                        // Set capturedData and capturedResponse to some garbage value up front to ensure that the handler gets passed nil
                        capturedData = Data()
                        capturedResponse = HTTPResponseImpl(statusCode: 9001)

                        let request = NSMutableURLRequest(url: NSURL(string: "http://")! as URL)
                        subject.doRequest(request as URLRequest) { data, response, error in
                            capturedData = data
                            capturedResponse = response
                            capturedError = error
                        }
                    }

                    it("calls the completion handler with nil response data") {
                        expect(capturedData).toEventually(beNil())
                    }

                    it("calls the completion handler with a nil response") {
                        expect(capturedResponse).toEventually(beNil())
                    }

                    it("calls the completion handler with an error that has NSError.localizedDescription as the details") {
                        expect(capturedError).toEventuallyNot(beNil())
                        expect(capturedError?.details).toEventually(equal("Could not connect to the server."))
                    }
                }
            }
        }
    }
}
