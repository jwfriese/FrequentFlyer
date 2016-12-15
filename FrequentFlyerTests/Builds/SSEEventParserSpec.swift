import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class SSEEventParserSpec: QuickSpec {
    override func spec() {
        describe("SSEEventParser") {
            var subject: SSEEventParser!

            beforeEach {
                subject = SSEEventParser()
            }

            describe("Parsing log output from events") {
                var result: LogEvent?
                var error: FFError?

                describe("When the data event type is 'log'") {
                    describe("When 'payload' data exists") {
                        beforeEach {
                            let eventDataString = "{\"event\":\"log\",\"data\":{\"payload\":\"turtle log message\"}}"
                            let event = SSEEvent(id: "1",
                                                 event: "event",
                                                 data: eventDataString
                            )

                            (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                        }

                        it("returns no error") {
                            expect(error).to(beNil())
                        }

                        it("returns a log event with the correct message") {
                            expect(result?.payload).to(equal("turtle log message"))
                        }
                    }

                    describe("When event data does not have 'payload'") {
                        beforeEach {
                            let eventDataString = "{\"event\":\"log\",\"data\":{\"somenonsense\":\"turtle log message\"}}"
                            let event = SSEEvent(id: "1",
                                                 event: "event",
                                                 data: eventDataString
                            )

                            (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                        }

                        it("returns an error") {
                            let expectedErrorMessage = "Invalid log event JSON: Missing 'payload' data"
                            expect(error?.details).to(equal(expectedErrorMessage))
                        }

                        it("returns no log event") {
                            expect(result).to(beNil())
                        }
                    }
                }

                describe("When the data event type is not 'log'") {
                    beforeEach {
                        let eventDataString = "{\"event\":\"crab-takeover\",\"data\":{\"payload\":\"turtle log message\"}}"
                        let event = SSEEvent(id: "1",
                                             event: "event",
                                             data: eventDataString
                        )

                        (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                    }

                    it("returns an error") {
                        let expectedErrorMessage = "Unsupported event type: 'crab-takeover'"
                        expect(error?.details).to(equal(expectedErrorMessage))
                    }

                    it("returns no log event") {
                        expect(result).to(beNil())
                    }
                }

                describe("When the data has no 'event'") {
                    beforeEach {
                        let eventDataString = "{\"data\":{\"payload\":\"turtle log message\"}}"
                        let event = SSEEvent(id: "1",
                                             event: "event",
                                             data: eventDataString
                        )

                        (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                    }

                    it("returns an error") {
                        let expectedErrorMessage = "Could read JSON data: 'event' descriptor field missing"
                        expect(error?.details).to(equal(expectedErrorMessage))
                    }

                    it("returns no log event") {
                        expect(result).to(beNil())
                    }
                }

                describe("When the event data JSON has no top-level 'data' field") {
                    beforeEach {
                        let eventDataString = "{\"event\":\"log\",\"wrong-field\":{\"payload\":\"turtle log message\"}}"
                        let event = SSEEvent(id: "1",
                                             event: "event",
                                             data: eventDataString
                        )

                        (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                    }

                    it("returns an error") {
                        let expectedErrorMessage = "Could read JSON data: Top-level 'data' field missing"
                        expect(error?.details).to(equal(expectedErrorMessage))
                    }

                    it("returns no log event") {
                        expect(result).to(beNil())
                    }
                }

                describe("When the event data JSON is not valid") {
                    beforeEach {
                        let eventDataString = "{invalid-json}}"
                        let event = SSEEvent(id: "1",
                                             event: "event",
                                             data: eventDataString
                        )

                        (result, error) = subject.parseConcourseEventFromSSEEvent(event: event)
                    }

                    it("returns an error") {
                        let expectedErrorMessage = "Could not parse event: Input SSEEvent data is not valid JSON"
                        expect(error?.details).to(equal(expectedErrorMessage))
                    }

                    it("returns no log event") {
                        expect(result).to(beNil())
                    }
                }
            }
        }
    }
}
