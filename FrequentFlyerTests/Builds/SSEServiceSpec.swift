import XCTest
import Quick
import Nimble

@testable import FrequentFlyer

class SSEServiceSpec: QuickSpec {
    class MockEventSourceCreator: EventSourceCreator {
        var capturedUrlString: String?
        var capturedHeaders: [String : String]?

        var returnedEventSource: EventSource?

        override func create(withURL url: String, headers: [String : String]) -> EventSource {
            capturedUrlString = url
            capturedHeaders = headers
            returnedEventSource = EventSource(url: url, headers: headers)
            return returnedEventSource!
        }
    }

    override func spec() {
        describe("SSEService") {
            var subject: SSEService!
            var mockEventSourceCreator: MockEventSourceCreator!

            beforeEach {
                mockEventSourceCreator = MockEventSourceCreator()

                subject = SSEService()
                subject.eventSourceCreator = mockEventSourceCreator
            }

            describe("Opening a connection to read a Concourse build's logs") {
                var connection: SSEConnection!

                beforeEach {
                    let target = Target(name: "turtle target", api: "https://turtle.com", teamName: "turtleTeam", token: Token(value: "tokenValue"))
                    let build = Build(id: 123, jobName: "turtleJob", status: "pending", pipelineName: "turtlePipeline")

                    connection = subject.openSSEConnection(target: target, build: build)
                }

                it("gets an EventSource using the EventSourceCreator") {
                    expect(mockEventSourceCreator.capturedUrlString).to(equal("https://turtle.com/api/v1/builds/123/events"))
                    expect(mockEventSourceCreator.capturedHeaders).to(equal(["Authorization":"Bearer tokenValue"]))
                }

                it("creates and returns a connection to access Concourse logs") {
                    expect(connection.urlString).to(equal("https://turtle.com/api/v1/builds/123/events"))
                }
            }
        }
    }
}
