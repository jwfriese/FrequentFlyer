import XCTest
import Quick
import Nimble

@testable import FrequentFlyer
import EventSource

class SSEConnectionSpec: QuickSpec {
    override func spec() {
        class MockEventSource: EventSource {
            var capturedURL: String?
            var capturedHeaders: [String : String]?
            var capturedOnMessagesReceived: (([SSEEvent]) -> ())?

            override init(url: String, headers: [String : String]) {
                super.init(url: url, headers: headers)
                capturedURL = url
                capturedHeaders = headers
            }

            override func onMessagesReceived(_ onMessagesReceivedCallback: @escaping (([SSEEvent]) -> Void)) {
                capturedOnMessagesReceived = onMessagesReceivedCallback
            }
        }

        class MockSSEEventParser: SSEEventParser {
            var capturedEvents: [SSEEvent] = [SSEEvent]()

            override func parseConcourseEventFromSSEEvent(event: SSEEvent) -> (log: LogEvent, error: FFError?) {
                capturedEvents.append(event)
                let logEvent = LogEvent(payload: event.data!)
                return (logEvent, nil)
            }
        }

        describe("SSEConnection") {
            var subject: SSEConnection!
            var mockEventSource: MockEventSource!
            var mockSSEEventParser: MockSSEEventParser!

            beforeEach {
                mockEventSource = MockEventSource(url: "http://turtlesource.com", headers: ["header":"value"])
                mockSSEEventParser = MockSSEEventParser()
                subject = SSEConnection(eventSource: mockEventSource, sseEventParser: mockSSEEventParser)
            }

            it("can say its EventSource's URL string") {
                expect(subject.urlString).to(equal("http://turtlesource.com"))
            }

            describe("Processing events from the event source") {
                var eventOne: SSEEvent!
                var eventTwo: SSEEvent!
                var returnedLogs: [LogEvent]?

                beforeEach {
                    guard let onMessagesCallback = mockEventSource.capturedOnMessagesReceived else {
                        fail("SSEConnection failed to register messages handler with its event source")
                        return
                    }

                    subject.onLogsReceived = { logs in
                        returnedLogs = logs
                    }

                    eventOne = SSEEvent(id: "1", event: "turtle event", data: "turtle data")
                    eventTwo = SSEEvent(id: "2", event: "crab event", data: "crab data")

                    onMessagesCallback([eventOne, eventTwo])
                }

                it("passes the events to the log parser") {
                    let expectedEvents: [SSEEvent] = [eventOne, eventTwo]
                    expect(mockSSEEventParser.capturedEvents).to(equal(expectedEvents))
                }

                it("calls the given logs received callback with the parsed logs") {
                    let expectedTurtleLog = LogEvent(payload: "turtle data")
                    let expectedCrabLog = LogEvent(payload: "crab data")
                    expect(returnedLogs).to(equal([expectedTurtleLog, expectedCrabLog]))
                }
            }
        }
    }
}
