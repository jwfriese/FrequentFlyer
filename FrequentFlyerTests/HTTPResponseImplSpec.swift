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
                        expect(HTTPResponseImpl(statusCode: 200).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(statusCode: 201).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(statusCode: 210).isSuccess).to(beTrue())
                        expect(HTTPResponseImpl(statusCode: 299).isSuccess).to(beTrue())
                    }
                }
                
                context("When any other status code") {
                    it("returns false") {
                        expect(HTTPResponseImpl(statusCode: 100).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(statusCode: 300).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(statusCode: 400).isSuccess).to(beFalse())
                        expect(HTTPResponseImpl(statusCode: 500).isSuccess).to(beFalse())
                    }
                }
            }
        }
    }
}
