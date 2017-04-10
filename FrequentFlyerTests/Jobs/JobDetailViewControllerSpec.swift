import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class JobDetailViewControllerSpec: QuickSpec {
    class MockLogsViewController: LogsViewController {
        override func viewDidLoad() {}

        var didCallFetchLogs = false
        override func fetchLogs() {
            didCallFetchLogs = true
        }
    }

    override func spec() {
        describe("JobDetailViewController") {
            var subject: JobDetailViewController!
            var mockLogsViewController: MockLogsViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockLogsViewController = MockLogsViewController()
                try! storyboard.bind(viewController: mockLogsViewController, toIdentifier: LogsViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewController(withIdentifier: JobDetailViewController.storyboardIdentifier) as! JobDetailViewController

                let target = Target(
                    name: "targetName",
                    api: "api",
                    teamName: "teamName",
                    token: Token(value: "tokenValue")
                )
                subject.target = target

                let pipeline = Pipeline(name: "pipeline")
                subject.pipeline = pipeline
            }

            describe("After the view loads") {
                describe("Setting up its control panel") {
                    describe("When only a finished build is available on the job") {
                        beforeEach {
                            let finishedBuild = BuildBuilder().withName("a finished build").withEndTime(1000).build()
                            subject.job = Job(name: "job_name", nextBuild: nil, finishedBuild: finishedBuild, groups: [])
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("sets the finished build on the control panel") {
                            let expectedBuild = BuildBuilder().withName("a finished build").withEndTime(1000).build()
                            expect(subject.controlPanel?.build).toEventually(equal(expectedBuild))
                        }

                        it("sets its pipeline on the control panel") {
                            let expectedPipeline = Pipeline(name: "pipeline")
                            expect(subject.controlPanel?.pipeline).toEventually(equal(expectedPipeline))
                        }

                        it("sets its target on the control panel") {
                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.controlPanel?.target).toEventually(equal(expectedTarget))
                        }

                        it("sets up its logs pane with the finished build") {
                            let expectedBuild = BuildBuilder().withName("a finished build").withEndTime(1000).build()
                            expect(subject.logsPane?.build).toEventually(equal(expectedBuild))

                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.logsPane?.target).toEventually(equal(expectedTarget))
                        }

                        it("asks its logs pane to fetch logs") {
                            expect(mockLogsViewController.didCallFetchLogs).to(beTrue())
                        }
                    }

                    describe("When only a next build is available on the job") {
                        beforeEach {
                            let nextBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            subject.job = Job(name: "job_name", nextBuild: nextBuild, finishedBuild: nil, groups: [])
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("sets the next build on the control panel") {
                            let expectedBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            expect(subject.controlPanel?.build).toEventually(equal(expectedBuild))
                        }

                        it("sets its pipeline on the control panel") {
                            let expectedPipeline = Pipeline(name: "pipeline")
                            expect(subject.controlPanel?.pipeline).toEventually(equal(expectedPipeline))
                        }

                        it("sets its target on the control panel") {
                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.controlPanel?.target).toEventually(equal(expectedTarget))
                        }

                        it("sets up its logs pane with the next build") {
                            let expectedBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            expect(subject.logsPane?.build).toEventually(equal(expectedBuild))

                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.logsPane?.target).toEventually(equal(expectedTarget))
                        }

                        it("asks its logs pane to fetch logs") {
                            expect(mockLogsViewController.didCallFetchLogs).to(beTrue())
                        }
                    }

                    describe("When both a finished build and a next build are available on the job") {
                        beforeEach {
                            let nextBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            let finishedBuild = BuildBuilder().withName("a finished build").withEndTime(1000).build()
                            subject.job = Job(name: "job_name", nextBuild: nextBuild, finishedBuild: finishedBuild, groups: [])
                            let _ = Fleet.setInAppWindowRootNavigation(subject)
                        }

                        it("sets the next build on the control panel") {
                            let expectedBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            expect(subject.controlPanel?.build).toEventually(equal(expectedBuild))
                        }

                        it("sets its pipeline on the control panel") {
                            let expectedPipeline = Pipeline(name: "pipeline")
                            expect(subject.controlPanel?.pipeline).toEventually(equal(expectedPipeline))
                        }

                        it("sets its target on the control panel") {
                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.controlPanel?.target).toEventually(equal(expectedTarget))
                        }

                        it("sets up its logs pane with the next build") {
                            let expectedBuild = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            expect(subject.logsPane?.build).toEventually(equal(expectedBuild))

                            let expectedTarget = Target(
                                name: "targetName",
                                api: "api",
                                teamName: "teamName",
                                token: Token(value: "tokenValue")
                            )
                            expect(subject.logsPane?.target).toEventually(equal(expectedTarget))
                        }

                        it("asks its logs pane to fetch logs") {
                            expect(mockLogsViewController.didCallFetchLogs).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}
