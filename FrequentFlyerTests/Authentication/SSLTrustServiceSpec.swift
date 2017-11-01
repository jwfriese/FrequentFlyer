import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class SSLTrustServiceSpec: QuickSpec {
    override func spec() {
        describe("SSLTrustService") {
            var subject: SSLTrustService!

            beforeEach {
                subject = SSLTrustService()
            }

            it("allows a flow of adding trust, accessing trust, and removing trust") {
                let url = "https://baseurl.com"
                expect(subject.hasRegisteredTrust(forBaseURL: url)).to(beFalse())

                subject.registerTrust(forBaseURL: url)
                expect(subject.hasRegisteredTrust(forBaseURL: url)).to(beTrue())

                subject.revokeTrust(forBaseURL: url)
                expect(subject.hasRegisteredTrust(forBaseURL: url)).to(beFalse())

                subject.registerTrust(forBaseURL: url)
                expect(subject.hasRegisteredTrust(forBaseURL: url)).to(beTrue())

                subject.clearAllTrust()
                expect(subject.hasRegisteredTrust(forBaseURL: url)).to(beFalse())
            }
        }
    }
}
