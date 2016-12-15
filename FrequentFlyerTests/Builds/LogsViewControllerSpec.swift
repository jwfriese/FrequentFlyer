import XCTest
import Quick
import Nimble
import Fleet

@testable import FrequentFlyer

class LogsViewControllerSpec: QuickSpec {
    override func spec() {

        class MockSSEService: SSEService {
            var capturedTarget: Target?
            var capturedBuild: Build?
            var returnedConnection: MockSSEConnection?

            override func openSSEConnection(target: Target, build: Build) -> SSEConnection {
                capturedTarget = target
                capturedBuild = build
                returnedConnection = MockSSEConnection()
                return returnedConnection!
            }
        }

        class MockSSEConnection: SSEConnection {
            init() {
                let eventSource = EventSource(url: "http://something.com")
                let sseEventParser = SSEEventParser()

                super.init(eventSource: eventSource, sseEventParser: sseEventParser)
            }
        }

        describe("LogsViewController") {
            var subject: LogsViewController!
            var mockSSEService: MockSSEService!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: LogsViewController.storyboardIdentifier) as! LogsViewController

                mockSSEService = MockSSEService()
                subject.sseService = mockSSEService

                subject.build = Build(id: 15, jobName: "turtle-job", status: "pending", pipelineName: "turtle-pipeline")
                subject.target = try! Factory.createTarget()
            }

            describe("After the view has loaded") {
                beforeEach {
                    Fleet.setApplicationWindowRootViewController(subject)
                }

                it("asks the logs service to begin collecting logs") {
                    let expectedTarget = try! Factory.createTarget()
                    let expectedBuild = Build(id: 15, jobName: "turtle-job", status: "pending", pipelineName: "turtle-pipeline")
                    expect(mockSSEService.capturedTarget).to(equal(expectedTarget))
                    expect(mockSSEService.capturedBuild).to(equal(expectedBuild))
                }

                describe("When the connection reports logs") {
                    beforeEach {
                        guard let logsCallback = mockSSEService.returnedConnection?.onLogsReceived else {
                            fail("Failed to set a callback for received logs on the SSE connection")
                            return
                        }

                        let turtleLogEvent = LogEvent(payload: "turtle log entry")
                        let crabLogEvent = LogEvent(payload: "crab log entry")
                        let logs = [turtleLogEvent, crabLogEvent]
                        logsCallback(logs)
                    }

                    it("appends the logs to the log view") {
                        expect(subject.logOutputView?.text).toEventually(contain("turtle log entry"))
                        expect(subject.logOutputView?.text).toEventually(contain("crab log entry"))
                    }
                }
            }
        }
    }
}
