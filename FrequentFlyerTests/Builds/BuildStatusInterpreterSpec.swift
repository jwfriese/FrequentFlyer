import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class BuildStatusInterpreterSpec: QuickSpec {
    override func spec() {
        describe("BuildStatusInterpreter") {
            var subject: BuildStatusInterpreter!

            beforeEach {
                subject = BuildStatusInterpreter()
            }

            it("can interpret various strings for \(BuildStatus.pending)") {
                expect(subject.interpret("pending")).to(equal(BuildStatus.pending))
                expect(subject.interpret("pending ")).to(equal(BuildStatus.pending))
                expect(subject.interpret("Pending")).to(equal(BuildStatus.pending))
                expect(subject.interpret("PENDING")).to(equal(BuildStatus.pending))
            }

            it("can interpret various strings for \(BuildStatus.started)") {
                expect(subject.interpret("started")).to(equal(BuildStatus.started))
                expect(subject.interpret("started ")).to(equal(BuildStatus.started))
                expect(subject.interpret("Started")).to(equal(BuildStatus.started))
                expect(subject.interpret("STARTED")).to(equal(BuildStatus.started))
            }

            it("can interpret various strings for \(BuildStatus.succeeded)") {
                expect(subject.interpret("succeeded")).to(equal(BuildStatus.succeeded))
                expect(subject.interpret("succeeded ")).to(equal(BuildStatus.succeeded))
                expect(subject.interpret("Succeeded")).to(equal(BuildStatus.succeeded))
                expect(subject.interpret("SUCCEEDED")).to(equal(BuildStatus.succeeded))
            }

            it("can interpret various strings for \(BuildStatus.failed)") {
                expect(subject.interpret("failed")).to(equal(BuildStatus.failed))
                expect(subject.interpret(" failed")).to(equal(BuildStatus.failed))
                expect(subject.interpret("Failed")).to(equal(BuildStatus.failed))
                expect(subject.interpret("FAILED")).to(equal(BuildStatus.failed))
            }

            it("can interpret various strings for \(BuildStatus.errored)") {
                expect(subject.interpret("errored")).to(equal(BuildStatus.errored))
                expect(subject.interpret(" errored ")).to(equal(BuildStatus.errored))
                expect(subject.interpret("Errored")).to(equal(BuildStatus.errored))
                expect(subject.interpret("ERRORED")).to(equal(BuildStatus.errored))
            }

            it("can interpret various strings for \(BuildStatus.aborted)") {
                expect(subject.interpret("aborted")).to(equal(BuildStatus.aborted))
                expect(subject.interpret("aborted ")).to(equal(BuildStatus.aborted))
                expect(subject.interpret("Aborted")).to(equal(BuildStatus.aborted))
                expect(subject.interpret("ABORTED")).to(equal(BuildStatus.aborted))
            }

            it("can interpret various strings for \(BuildStatus.paused)") {
                expect(subject.interpret("paused")).to(equal(BuildStatus.paused))
                expect(subject.interpret("    paused    ")).to(equal(BuildStatus.paused))
                expect(subject.interpret("Paused")).to(equal(BuildStatus.paused))
                expect(subject.interpret("PAUSED")).to(equal(BuildStatus.paused))
            }

            it("returns nil when it cannot interpret the string successfully") {
                expect(subject.interpret("")).to(beNil())
                expect(subject.interpret("somehtigdjba")).to(beNil())
            }
        }
    }
}
