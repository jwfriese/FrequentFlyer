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
                    var capturedData: NSData?
                    var capturedResponse: HTTPResponse?
                    var capturedError: Error?

                    beforeEach {
                        // Set capturedError to some garbage value up front to ensure that the handler gets passed nil
                        capturedError = BasicError(details: "test error")

                        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8181/successyeah")!)
                        subject.doRequest(request) { data, response, error in
                            capturedData = data
                            capturedResponse = response
                            capturedError = error
                        }
                    }

                    it("calls the completion handler with the response data") {
                        let testServerData = "{\"success\" : \"yeah\" }".dataUsingEncoding(NSUTF8StringEncoding)
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
                    var capturedData: NSData?
                    var capturedResponse: HTTPResponse?
                    var capturedError: Error?

                    beforeEach {
                        // Set capturedData to some garbage value up front to ensure that the handler gets passed nil
                        capturedData = NSData()

                        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8181/errorplease")!)
                        subject.doRequest(request) { data, response, error in
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
                    var capturedData: NSData?
                    var capturedResponse: HTTPResponse?
                    var capturedError: Error?

                    beforeEach {
                        // Set capturedData and capturedResponse to some garbage value up front to ensure that the handler gets passed nil
                        capturedData = NSData()
                        capturedResponse = HTTPResponseImpl(statusCode: 9001)

                        let request = NSMutableURLRequest(URL: NSURL(string: "http://")!)
                        subject.doRequest(request) { data, response, error in
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
