import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class JobsViewControllerSpec: QuickSpec {
    class MockJobsService: JobsService {
        var capturedTarget: Target?
        var capturedPipeline: Pipeline?
        var jobsSubject = PublishSubject<[Job]>()

        override func getJobs(forTarget target: Target, pipeline: Pipeline) -> Observable<[Job]> {
            capturedTarget = target
            capturedPipeline = pipeline
            return jobsSubject
        }
    }

    class MockElapsedTimePrinter: ElapsedTimePrinter {
        var capturedTime: TimeInterval?
        var toReturnResult = ""

        override func printTime(since timePassedInSeconds: TimeInterval?) -> String {
            capturedTime = timePassedInSeconds
            return toReturnResult
        }
    }

    override func spec() {
        describe("JobsViewController") {
            var subject: JobsViewController!
            var mockJobsService: MockJobsService!
            var mockElapsedTimePrinter: MockElapsedTimePrinter!

            var mockJobDetailViewController: JobDetailViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockJobDetailViewController = try! storyboard.mockIdentifier(JobDetailViewController.storyboardIdentifier, usingMockFor: JobDetailViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: JobsViewController.storyboardIdentifier) as! JobsViewController

                let pipeline = Pipeline(name: "turtle pipeline")
                subject.pipeline = pipeline

                let target = Target(
                    name: "turtle target",
                    api: "turtle api",
                    teamName: "turtle team",
                    token: Token(value: "turtle token value")
                )
                subject.target = target

                mockJobsService = MockJobsService()
                subject.jobsTableViewDataSource.jobsService = mockJobsService

                mockElapsedTimePrinter = MockElapsedTimePrinter()
                subject.jobsTableViewDataSource.elapsedTimePrinter = mockElapsedTimePrinter
            }

            describe("After the view loads") {
                beforeEach {
                    mockElapsedTimePrinter.toReturnResult = "5 min ago"
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).toEventually(equal("turtle pipeline"))
                }

                it("calls out to the \(JobsService.self)") {
                    let expectedTarget = Target(
                        name: "turtle target",
                        api: "turtle api",
                        teamName: "turtle team",
                        token: Token(value: "turtle token value")
                    )

                    let expectedPipeline = Pipeline(name: "turtle pipeline")

                    expect(mockJobsService.capturedTarget).toEventually(equal(expectedTarget))
                    expect(mockJobsService.capturedPipeline).toEventually(equal(expectedPipeline))
                }

                describe("When the \(JobsService.self) resolves with jobs") {
                    beforeEach {
                        let finishedTurtleBuild = BuildBuilder().withStatus(.failed).withEndTime(1000).build()
                        let turtleJob = Job(name: "turtle job", nextBuild: nil, finishedBuild: finishedTurtleBuild, groups: [])

                        let nextCrabBuild = BuildBuilder().withStatus(.pending).withStartTime(500).build()
                        let crabJob = Job(name: "crab job", nextBuild: nextCrabBuild, finishedBuild: nil, groups: [])

                        let puppyJob = Job(name: "puppy job", nextBuild: nil, finishedBuild: nil, groups: [])

                        mockJobsService.jobsSubject.onNext([turtleJob, crabJob, puppyJob])
                        mockJobsService.jobsSubject.onCompleted()
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("inserts a row for each job returned by the service") {
                        expect(subject.jobsTableView?.numberOfRows(inSection: 0)).toEventually(equal(3))
                    }

                    it("creates a cell in each row for each build with correct pipeline name returned by the service") {
                        let cellOneOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                        guard let cellOne = cellOneOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellOne.jobNameLabel?.text).to(equal("turtle job"))

                        let cellTwoOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 1, section: 0))
                        guard let cellTwo = cellTwoOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellTwo.jobNameLabel?.text).to(equal("crab job"))

                        let cellThreeOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 2, section: 0))
                        guard let cellThree = cellThreeOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellThree.jobNameLabel?.text).to(equal("puppy job"))
                    }

                    it("will display data about the latest finished build if no next build available") {
                        let cellOneOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                        guard let cellOne = cellOneOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }

                        expect(cellOne.latestJobLastEventTimeLabel?.text).to(equal("5 min ago"))
                        expect(cellOne.buildStatusBadge?.status).to(equal(BuildStatus.failed))
                    }

                    it("will display data about the next build if one is available") {
                        let cellTwoOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 1, section: 0))
                        guard let cellTwo = cellTwoOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }

                        expect(cellTwo.latestJobLastEventTimeLabel?.text).to(equal("5 min ago"))
                        expect(cellTwo.buildStatusBadge?.status).to(equal(BuildStatus.pending))
                    }

                    it("will display '--' and no status badge if neither type of build is available") {
                        let cellThreeOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 2, section: 0))
                        guard let cellThree = cellThreeOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }

                        expect(cellThree.latestJobLastEventTimeLabel?.text).to(equal("--"))
                        expect(cellThree.buildStatusBadge?.isHidden).to(beTrue())
                    }

                    describe("Selecting one of the job cells") {
                        beforeEach {
                            try! subject.jobsTableView?.selectRow(at: IndexPath(row: 1, section: 0))
                        }

                        it("presents a job detail view controller") {
                            let jobDetailViewController: () -> JobDetailViewController? = {
                                return Fleet.getApplicationScreen()?.topmostViewController as? JobDetailViewController
                            }

                            expect(jobDetailViewController()).toEventually(beIdenticalTo(mockJobDetailViewController))
                            expect(jobDetailViewController()?.job?.name).toEventually(equal("crab job"))

                            let expectedPipeline = Pipeline(name: "turtle pipeline")
                            expect(jobDetailViewController()?.pipeline).toEventually(equal(expectedPipeline))

                            let expectedTarget = Target(
                                name: "turtle target",
                                api: "turtle api",
                                teamName: "turtle team",
                                token: Token(value: "turtle token value")
                            )
                            expect(jobDetailViewController()?.target).toEventually(equal(expectedTarget))
                        }

                        it("immediately deselects the cell") {
                            let selectedCell = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                            expect(selectedCell).toEventuallyNot(beNil())
                            expect(selectedCell?.isHighlighted).toEventually(beFalse())
                            expect(selectedCell?.isSelected).toEventually(beFalse())
                        }
                    }
                }
            }
        }
    }
}
