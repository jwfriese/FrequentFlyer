import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class JobsViewControllerSpec: QuickSpec {
    class MockJobsDataStreamProducer: JobsDataStreamProducer {
        var jobGroupsSubject = PublishSubject<[JobGroupSection]>()
        var capturedTarget: Target!
        var capturedPipeline: Pipeline!

        override func openStream(forTarget target: Target, pipeline: Pipeline) -> Observable<[JobGroupSection]> {
            capturedTarget = target
            capturedPipeline = pipeline
            return jobGroupsSubject
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

    class MockKeychainWrapper: KeychainWrapper {
        var didCallDelete = false

        override func deleteTarget() {
            didCallDelete = true
        }
    }

    override func spec() {
        describe("JobsViewController") {
            var subject: JobsViewController!
            var mockJobsDataStreamProducer: MockJobsDataStreamProducer!
            var mockElapsedTimePrinter: MockElapsedTimePrinter!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockJobDetailViewController: JobDetailViewController!
            var mockConcourseEntryViewController: ConcourseEntryViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockJobDetailViewController = try! storyboard.mockIdentifier(JobDetailViewController.storyboardIdentifier, usingMockFor: JobDetailViewController.self)
                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

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

                mockJobsDataStreamProducer = MockJobsDataStreamProducer()
                subject.jobsDataStreamProducer = mockJobsDataStreamProducer

                mockElapsedTimePrinter = MockElapsedTimePrinter()
                subject.jobsTableViewDataSource.elapsedTimePrinter = mockElapsedTimePrinter

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper
            }

            describe("After the view loads") {
                beforeEach {
                    mockElapsedTimePrinter.toReturnResult = "5 min ago"
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).toEventually(equal("turtle pipeline"))
                }

                it("has an active loading indicator") {
                    expect(subject.loadingIndicator?.isAnimating).toEventually(beTrue())
                    expect(subject.loadingIndicator?.isHidden).toEventually(beFalse())
                }

                it("hides the table views row lines while there is no content") {
                    expect(subject.jobsTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.none))
                }

                it("opens the data stream") {
                    let expectedPipeline = Pipeline(name: "turtle pipeline")
                    expect(mockJobsDataStreamProducer.capturedPipeline).to(equal(expectedPipeline))

                    let expectedTarget = Target(
                        name: "turtle target",
                        api: "turtle api",
                        teamName: "turtle team",
                        token: Token(value: "turtle token value")
                    )
                    expect(mockJobsDataStreamProducer.capturedTarget).to(equal(expectedTarget))
                }

                describe("When the jobs data stream spits out some jobs") {
                    beforeEach {
                        let finishedTurtleBuild = BuildBuilder().withStatus(.failed).withEndTime(1000).build()
                        let turtleJob = Job(name: "turtle job", nextBuild: nil, finishedBuild: finishedTurtleBuild, groups: ["turtle-group"])
                        var turtleSection = JobGroupSection()
                        turtleSection.items.append(turtleJob)

                        let nextCrabBuild = BuildBuilder().withStatus(.pending).withStartTime(500).build()
                        let crabJob = Job(name: "crab job", nextBuild: nextCrabBuild, finishedBuild: nil, groups: ["crab-group"])

                        let anotherCrabBuild = BuildBuilder().withStatus(.aborted).withStartTime(501).build()
                        let anotherCrabJob = Job(name: "another crab job", nextBuild: anotherCrabBuild, finishedBuild: nil, groups: ["crab-group"])
                        var crabSection = JobGroupSection()
                        crabSection.items.append(contentsOf: [crabJob, anotherCrabJob])

                        let puppyJob = Job(name: "puppy job", nextBuild: nil, finishedBuild: nil, groups: [])
                        var puppySection = JobGroupSection()
                        puppySection.items.append(puppyJob)

                        mockJobsDataStreamProducer.jobGroupsSubject.onNext([turtleSection, crabSection, puppySection])
                        mockJobsDataStreamProducer.jobGroupsSubject.onCompleted()
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.jobsTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("inserts a row for each job returned by the service, for each section created") {
                        expect(subject.jobsTableView?.numberOfRows(inSection: 0)).toEventually(equal(1))
                        expect(subject.jobsTableView?.numberOfRows(inSection: 1)).toEventually(equal(2))
                        expect(subject.jobsTableView?.numberOfRows(inSection: 2)).toEventually(equal(1))
                    }

                    it("inserts a section for each group defined by the service, plus one for the `ungrouped` section") {
                        expect(subject.jobsTableView?.numberOfSections).toEventually(equal(3))
                    }

                    it("creates a cell in each row for each build with correct pipeline name returned by the service") {
                        let cellOneOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                        guard let cellOne = cellOneOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellOne.jobNameLabel?.text).to(equal("turtle job"))

                        let cellTwoOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 1))
                        guard let cellTwo = cellTwoOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellTwo.jobNameLabel?.text).to(equal("crab job"))

                        let cellThreeOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 1, section: 1))
                        guard let cellThree = cellThreeOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellThree.jobNameLabel?.text).to(equal("another crab job"))

                        let cellFourOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 2))
                        guard let cellFour = cellFourOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }
                        expect(cellFour.jobNameLabel?.text).to(equal("puppy job"))
                    }

                    it("creates headers for each group, where the group name in the table matches the jobs' group name") {
                        expect(subject.jobsTableViewDataSource.tableView(UITableView(), titleForHeaderInSection: 0)).toEventually(equal("turtle-group"))
                        expect(subject.jobsTableViewDataSource.tableView(UITableView(), titleForHeaderInSection: 1)).toEventually(equal("crab-group"))
                        expect(subject.jobsTableViewDataSource.tableView(UITableView(), titleForHeaderInSection: 2)).toEventually(equal("ungrouped"))
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
                        let cellTwoOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 1))
                        guard let cellTwo = cellTwoOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }

                        expect(cellTwo.latestJobLastEventTimeLabel?.text).to(equal("5 min ago"))
                        expect(cellTwo.buildStatusBadge?.status).to(equal(BuildStatus.pending))
                    }

                    it("will display '--' and no status badge if neither type of build is available") {
                        let cellThreeOpt = subject.jobsTableView?.cellForRow(at: IndexPath(row: 0, section: 2))
                        guard let cellThree = cellThreeOpt as? JobsTableViewCell else {
                            fail("Failed to fetch a \(JobsTableViewCell.self)")
                            return
                        }

                        expect(cellThree.latestJobLastEventTimeLabel?.text).to(equal("--"))
                        expect(cellThree.buildStatusBadge?.isHidden).to(beTrue())
                    }

                    describe("Selecting one of the job cells") {
                        beforeEach {
                            try! subject.jobsTableView?.selectRow(at: IndexPath(row: 0, section: 1))
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

                describe("When the jobs data stream spits out an 'Unauthorized' error") {
                    beforeEach {
                        mockJobsDataStreamProducer.jobGroupsSubject.onError(AuthorizationError())
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.jobsTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("presents an alert describing the authorization error") {
                        let alert: () -> UIAlertController? = {
                            return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                        }

                        expect(alert()).toEventuallyNot(beNil())
                        expect(alert()?.title).toEventually(equal("Unauthorized"))
                        expect(alert()?.message).toEventually(equal("Your credentials have expired. Please authenticate again."))
                    }

                    describe("Tapping the 'Log Out' button on the alert") {
                        it("pops itself back to the initial page") {
                            let screen = Fleet.getApplicationScreen()
                            var didTapLogOut = false
                            let assertLogOutTappedBehavior = { () -> Bool in
                                if didTapLogOut {
                                    return screen?.topmostViewController === mockConcourseEntryViewController
                                }

                                if let alert = screen?.topmostViewController as? UIAlertController {
                                    try! alert.tapAlertAction(withTitle: "Log Out")
                                    didTapLogOut = true
                                }

                                return false
                            }

                            expect(assertLogOutTappedBehavior()).toEventually(beTrue())
                        }

                        it("asks its \(KeychainWrapper.self) to delete its target") {
                            let alert: () -> UIAlertController? = { _ in
                                return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                            }

                            var alertDidAppear = false
                            var didAttemptLogOutTap = false
                            let assertDidDeleteFromKeychain: () -> Bool = { _ in
                                if !alertDidAppear {
                                    if alert() != nil {
                                        alertDidAppear = true
                                    }

                                    return false
                                }

                                if !didAttemptLogOutTap {
                                    try! alert()!.tapAlertAction(withTitle: "Log Out")
                                    didAttemptLogOutTap = true
                                    return false
                                }

                                return mockKeychainWrapper.didCallDelete
                            }

                            expect(assertDidDeleteFromKeychain()).toEventually(beTrue())
                        }
                    }
                }
            }
        }
    }
}
