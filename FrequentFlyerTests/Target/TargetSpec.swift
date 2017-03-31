import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TargetSpec: QuickSpec {
    override func spec() {
        describe("Saveability to the keychain") {
            it("has a static variable for service name") {
                expect(Target.serviceName).to(equal("Authentication"))
            }

            it("can produce data to save") {
                let target = Target(name: "turtle target",
                                    api: "turtle concourse URL",
                                    teamName: "turtle team",
                                    token: Token(value: "super secret token")
                )
                expect(target.data["name"] as? String).to(equal("turtle target"))
                expect(target.data["api"] as? String).to(equal("turtle concourse URL"))
                expect(target.data["teamName"] as? String).to(equal("turtle team"))
                expect(target.data["token"] as? String).to(equal("super secret token"))
            }
        }

    }
}
