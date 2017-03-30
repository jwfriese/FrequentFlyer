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

    override func spec() {
        describe("JobsViewController") {
            var subject: JobsViewController!
            var mockJobsService: MockJobsService!

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
                subject.jobsService = mockJobsService
            }

            describe("After the view loads") {
                beforeEach {
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

                it("has one section in its table view") {
                    expect(subject.jobsTableView?.numberOfSections).toEventually(equal(1))
                }

                describe("When the \(JobsService.self) resolves with jobs") {
                    beforeEach {
                        let turtleJob = Job(name: "turtle job", builds: [])
                        let crabJob = Job(name: "crab job", builds: [])

                        mockJobsService.jobsSubject.onNext([turtleJob, crabJob])
                        mockJobsService.jobsSubject.onCompleted()
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("inserts a row for each job returned by the service") {
                        expect(subject.jobsTableView?.numberOfRows(inSection: 0)).toEventually(equal(2))
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
                            expect(jobDetailViewController()?.job).toEventually(equal(Job(name: "crab job", builds: [])))
                        }
                    }
                }
            }
        }
    }
}
