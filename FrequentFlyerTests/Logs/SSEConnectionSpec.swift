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
            var capturedOnEventDispatched: ((SSEMessageEvent) -> ())?
            var capturedOnError: ((NSError?) -> ())?

            override init(url: String, headers: [String : String]) {
                super.init(url: url, headers: headers)
                capturedURL = url
                capturedHeaders = headers
            }

            override func onEventDispatched(_ onEventDispatchedCallback: @escaping ((SSEMessageEvent) -> Void)) {
                capturedOnEventDispatched = onEventDispatchedCallback
            }

            override func onError(_ onErrorCallback: @escaping ((NSError?) -> Void)) {
                capturedOnError = onErrorCallback
            }
        }

        class MockSSEMessageEventParser: SSEMessageEventParser {
            var capturedEvents: [SSEMessageEvent] = [SSEMessageEvent]()

            override func parseConcourseEventFromSSEMessageEvent(event: SSEMessageEvent) -> (log: LogEvent, error: FFError?) {
                capturedEvents.append(event)
                let logEvent = LogEvent(payload: event.data)
                return (logEvent, nil)
            }
        }

        describe("SSEConnection") {
            var subject: SSEConnection!
            var mockEventSource: MockEventSource!
            var mockSSEMessageEventParser: MockSSEMessageEventParser!

            beforeEach {
                mockEventSource = MockEventSource(url: "http://turtlesource.com", headers: ["header":"value"])
                mockSSEMessageEventParser = MockSSEMessageEventParser()
                subject = SSEConnection(eventSource: mockEventSource, sseEventParser: mockSSEMessageEventParser)
            }

            it("can say its EventSource's URL string") {
                expect(subject.urlString).to(equal("http://turtlesource.com"))
            }

            describe("Processing events from the event source") {
                var eventOne: SSEMessageEvent!
                var eventTwo: SSEMessageEvent!
                var returnedLogs: [LogEvent]!

                beforeEach {
                    guard let onEventDispatchedCallback = mockEventSource.capturedOnEventDispatched else {
                        fail("\(SSEConnection.self) failed to register messages handler with its event source")
                        return
                    }

                    returnedLogs = [LogEvent]()

                    let callback: ([LogEvent]) -> () = { logs in
                        returnedLogs.append(contentsOf: logs)
                    }

                    subject.onLogsReceived = callback

                    eventOne = SSEMessageEvent(lastEventId: "1", type: "turtle event", data: "turtle data")
                    eventTwo = SSEMessageEvent(lastEventId: "2", type: "crab event", data: "crab data")

                    onEventDispatchedCallback(eventOne)
                    onEventDispatchedCallback(eventTwo)
                }

                it("passes the events to the log parser") {
                    let expectedEvents: [SSEMessageEvent] = [eventOne, eventTwo]
                    expect(mockSSEMessageEventParser.capturedEvents).to(equal(expectedEvents))
                }

                it("calls the given logs received callback with the parsed logs") {
                    let expectedTurtleLog = LogEvent(payload: "turtle data")
                    let expectedCrabLog = LogEvent(payload: "crab data")
                    expect(returnedLogs).to(equal([expectedTurtleLog, expectedCrabLog]))
                }
            }

            describe("When the connection errors out") {
                var didCallErrorHandler = false
                let error = NSError()
                var calledError: NSError?

                beforeEach {
                    guard let onErrorCallback = mockEventSource.capturedOnError else {
                        fail("\(SSEConnection.self) failed to register error handler with its event source")
                        return
                    }

                    subject.onError = { error in
                        didCallErrorHandler = true
                        calledError = error
                    }

                    onErrorCallback(error)
                }

                it("calls the given error handler") {
                    expect(didCallErrorHandler).toEventually(beTrue())
                    expect(calledError).toEventually(beIdenticalTo(error))
                }
            }
        }
    }
}
