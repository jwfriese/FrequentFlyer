import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class HTTPResponseImplSpec: QuickSpec {
    override func spec() {
        describe("HTTPResponseImpl") {
            describe("isSuccess") {
                context("When 200-type status code") {
                    it("returns true") {
                        expect(HTTPResponseImpl(body: nil, statusCode: 200).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(body: nil, statusCode: 201).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(body: nil, statusCode: 210).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(body: nil, statusCode: 299).isSuccess).to(beTrue())
                    }
                }

                context("When any other status code") {
                    it("returns false") {
                        expect(HTTPResponseImpl(body: nil, statusCode: 100).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(body: nil, statusCode: 300).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(body: nil, statusCode: 400).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(body: nil, statusCode: 500).isSuccess).to(beFalse())
                    }
                }
            }
        }
    }
}
