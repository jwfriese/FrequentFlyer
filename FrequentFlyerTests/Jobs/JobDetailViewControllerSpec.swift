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

                let job = Job(
                    name: "turtle job",
                    builds: [
                        Build(
                            id: 1,
                            name: "some build",
                            teamName: "turtle team",
                            jobName: "turtle job",
                            status: "build status",
                            pipelineName: "turtle pipeline"
                        )
                    ]
                )
                subject.job = job

                let pipeline = Pipeline(name: "pipeline")
                subject.pipeline = pipeline
            }

            describe("After the view loads") {
                beforeEach {
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).toEventually(equal("turtle job"))
                }

                it("sets up its control panel") {
                    expect(subject.controlPanel?.latestJobNameLabel?.text).toEventually(equal("some build"))
                    expect(subject.controlPanel?.latestJobStatusLabel?.text).toEventually(equal("build status"))
                    expect(subject.controlPanel?.pipeline).toEventually(equal(Pipeline(name: "pipeline")))

                    let expectedJob = Job(
                        name: "turtle job",
                        builds: [
                            Build(
                                id: 1,
                                name: "some build",
                                teamName: "turtle team",
                                jobName: "turtle job",
                                status: "build status",
                                pipelineName: "turtle pipeline"
                            )
                        ]
                    )
                    expect(subject.controlPanel?.job).toEventually(equal(expectedJob))

                    let expectedTarget = Target(
                        name: "targetName",
                        api: "api",
                        teamName: "teamName",
                        token: Token(value: "tokenValue")
                    )
                    expect(subject.controlPanel?.target).toEventually(equal(expectedTarget))
                }

                it("sets up its logs pane") {
                    let expectedBuild = Build(
                        id: 1,
                        name: "some build",
                        teamName: "turtle team",
                        jobName: "turtle job",
                        status: "build status",
                        pipelineName: "turtle pipeline"
                    )
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
