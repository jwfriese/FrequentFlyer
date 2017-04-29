import XCTest
import Quick
import Nimble
import Fleet

@testable import FrequentFlyer
import EventSource

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
                let sseEventParser = SSEMessageEventParser()

                super.init(eventSource: eventSource, sseEventParser: sseEventParser)
            }
        }

        class MockLogsStylingParser: LogsStylingParser {
            private var toReturnMap = [String : String]()

            func mockStripStylingCoding(when input: String, thenReturn toReturn: String) {
                toReturnMap[input] = toReturn
            }

            override func stripStylingCoding(originalString: String) -> String {
                if let string = toReturnMap[originalString] {
                    return string
                }

                return ""
            }
        }

        describe("LogsViewController") {
            var subject: LogsViewController!
            var mockSSEService: MockSSEService!
            var mockLogsStylingParser: MockLogsStylingParser!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: LogsViewController.storyboardIdentifier) as! LogsViewController

                mockSSEService = MockSSEService()
                subject.sseService = mockSSEService

                mockLogsStylingParser = MockLogsStylingParser()
                subject.logsStylingParser = mockLogsStylingParser

                subject.build = BuildBuilder().withName("LogsViewControllerBuild").build()
                subject.target = try! Factory.createTarget()
            }

            describe("After the view has loaded") {
                beforeEach {
                    Fleet.setAsAppWindowRoot(subject)
                }

                describe("When requested to fetch logs") {
                    beforeEach {
                        subject.fetchLogs()
                    }

                    it("asks the logs service to begin collecting logs") {
                        let expectedTarget = try! Factory.createTarget()
                        let expectedBuild = BuildBuilder().withName("LogsViewControllerBuild").build()
                        expect(mockSSEService.capturedTarget).to(equal(expectedTarget))
                        expect(mockSSEService.capturedBuild).to(equal(expectedBuild))
                    }

                    it("starts a loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).to(beTrue())
                    }

                    describe("When the connection reports logs") {
                        beforeEach {
                            guard let logsCallback = mockSSEService.returnedConnection?.onLogsReceived else {
                                fail("Failed to set a callback for received logs on the SSE connection")
                                return
                            }

                            let turtleLogEvent = LogEvent(payload: "turtle log entry")
                            let crabLogEvent = LogEvent(payload: "crab log entry")

                            mockLogsStylingParser.mockStripStylingCoding(when: "turtle log entry", thenReturn: "parsed turtle log entry")
                            mockLogsStylingParser.mockStripStylingCoding(when: "crab log entry", thenReturn: "parsed crab log entry")

                            let logs = [turtleLogEvent, crabLogEvent]
                            logsCallback(logs)
                        }

                        it("appends the logs to the log view") {
                            expect(subject.logOutputView?.text).toEventually(contain("parsed turtle log entry"))
                            expect(subject.logOutputView?.text).toEventually(contain("parsed crab log entry"))
                        }

                        it("stops any active loading indicator") {
                            expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        }
                    }
                }
            }
        }
    }
}
