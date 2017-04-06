import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class ElapsedTimePrinterSpec: QuickSpec {
    class MockTimepiece: Timepiece {
        var toReturnNow = Date(timeIntervalSince1970: 0)

        override func now() -> Date {
            return toReturnNow
        }
    }

    override func spec() {
        describe("ElapsedTimePrinter") {
            var subject: ElapsedTimePrinter!
            var mockTimepiece: MockTimepiece!

            let secondsSinceEpoch = TimeInterval(100000)
            let now = Date(timeIntervalSince1970: secondsSinceEpoch)

            beforeEach {
                subject = ElapsedTimePrinter()

                mockTimepiece = MockTimepiece()
                mockTimepiece.toReturnNow = now
                subject.timepiece = mockTimepiece
            }

            describe("Printing a human-readable representation of time elapsed") {
                var result: String!

                describe("When input it nil") {
                    beforeEach {
                        result = subject.printTime(since: nil)
                    }

                    it("pretty prints") {
                        expect(result).to(equal("--"))
                    }
                }
                describe("When the given time is in the past") {
                    describe("When the time is less than a minute ago") {
                        beforeEach {
                            let thirtySecondsAgo = TimeInterval(secondsSinceEpoch - 30)
                            result = subject.printTime(since: thirtySecondsAgo)
                        }

                        it("pretty prints") {
                            expect(result).to(equal("30s ago"))
                        }
                    }

                    describe("When the time is more than a minute and less than an hour ago") {
                        beforeEach {
                            let tenMinutesAgo = TimeInterval(secondsSinceEpoch - 600)
                            result = subject.printTime(since: tenMinutesAgo)
                        }

                        it("pretty prints") {
                            expect(result).to(equal("10m ago"))
                        }
                    }

                    describe("When the time is more than an hour and less than 24 hours ago") {
                        beforeEach {
                            let fourHours = TimeInterval(4 * 60 * 60)
                            let fourHoursAgo = TimeInterval(secondsSinceEpoch - fourHours)
                            result = subject.printTime(since: fourHoursAgo)
                        }

                        it("pretty prints") {
                            expect(result).to(equal("4h ago"))
                        }
                    }

                    describe("When the time is more than 24 hours ago") {
                        beforeEach {
                            let elevenDays = TimeInterval(11 * 24 * 60 * 60)
                            let elevenDaysAgo = TimeInterval(secondsSinceEpoch - elevenDays)
                            result = subject.printTime(since: elevenDaysAgo)
                        }

                        it("pretty prints") {
                            expect(result).to(equal("11d ago"))
                        }
                    }
                }

                describe("When the given time is in the future") {
                    beforeEach {
                        let thirtySecondsInTheFuture = TimeInterval(secondsSinceEpoch + 30)
                        result = subject.printTime(since: thirtySecondsInTheFuture)
                    }

                    it("pretty prints") {
                        expect(result).to(equal("--"))
                    }
                }
            }
        }
    }
}
