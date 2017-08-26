import XCTest
import Quick
import Nimble
import RxSwift
@testable import FrequentFlyer

class HTTPClientSpec: QuickSpec {
    override func spec() {
        describe("HTTPClient") {
            var subject: HTTPClient!

            beforeEach {
                subject = HTTPClient()
            }

            describe("Performing a request") {
                var http$: Observable<HTTPResponse>!
                var result: StreamResult<HTTPResponse>!

                context("When the request returns with a success response") {
                    beforeEach {
                        let request = URLRequest(url: NSURL(string: "http://localhost:8181/successyeah")! as URL)

                        http$ = subject.perform(request: request)
                        result = StreamResult(http$)
                    }

                    it("shows the spinner while the request is loading") {
                        expect(UIApplication.shared.isNetworkActivityIndicatorVisible).toEventually(beTrue())
                    }

                    it("hides the spinner when the request is complete") {
                        expect(UIApplication.shared.isNetworkActivityIndicatorVisible).toEventually(beFalse())
                    }

                    it("calls the completion handler with the response data") {
                        let testServerData = "{\"success\" : \"yeah\" }".data(using: String.Encoding.utf8)
                        expect(result.elements.first).toEventuallyNot(beNil())
                        expect(result.elements.first?.body).toEventually(equal(testServerData))
                        expect(result.elements.first?.statusCode).toEventually(equal(200))
                    }

                    it("calls the completion handler with a nil error") {
                        expect(result.error).toEventually(beNil())
                    }
                }

                context("When the request returns with an error-type response") {
                    beforeEach {
                        let request = URLRequest(url: NSURL(string: "http://localhost:8181/errorplease")! as URL)

                        http$ = subject.perform(request: request)
                        result = StreamResult(http$)
                    }

                    it("calls the completion handler with the response") {
                        expect(result.elements.first).toEventuallyNot(beNil())
                        expect(result.elements.first?.body).toEventually(equal("{\"error\" : \"here it is\"}".data(using: String.Encoding.utf8)))
                        expect(result.elements.first?.statusCode).toEventually(equal(500))
                    }

                    it("calls the completion handler with a nil error") {
                        expect(result.error).toEventually(beNil())
                    }
                }

                context("When the request completely bombs") {
                    beforeEach {
                        let request = URLRequest(url: NSURL(string: "http://")! as URL)

                        http$ = subject.perform(request: request)
                        result = StreamResult(http$)
                    }

                    it("calls the completion handler with a nil response") {
                        expect(result.elements.first).toEventually(beNil())
                    }

                    it("calls the completion handler with an error that has NSError.localizedDescription as the details") {
                        expect(result.error).toEventuallyNot(beNil())
                        expect(result.error?.localizedDescription).toEventually(equal("Could not connect to the server."))
                    }
                }
            }
        }
    }
}
