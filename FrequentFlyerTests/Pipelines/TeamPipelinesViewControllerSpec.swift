import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class TeamPipelinesViewControllerSpec: QuickSpec {
    class MockTeamPipelinesService: TeamPipelinesService {
        var capturedTarget: Target?
        var capturedCompletion: (([Pipeline]?, FFError?) -> ())?

        override func getPipelines(forTarget target: Target, completion: (([Pipeline]?, FFError?) -> ())?) {
            capturedTarget = target
            capturedCompletion = completion
        }
    }

    class MockKeychainWrapper: KeychainWrapper {
        var didCallDelete = false

        override func deleteTarget() {
            didCallDelete = true
        }
    }

    override func spec() {
        describe("TeamPipelinesViewController"){
            var subject: TeamPipelinesViewController!
            var mockTeamPipelinesService: MockTeamPipelinesService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockBuildsViewController: BuildsViewController!
            var mockConcourseEntryViewController: ConcourseEntryViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: TeamPipelinesViewController.storyboardIdentifier) as! TeamPipelinesViewController

                mockBuildsViewController = try! storyboard.mockIdentifier(BuildsViewController.storyboardIdentifier, usingMockFor: BuildsViewController.self)
                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

                subject.target = Target(name: "turtle target",
                    api: "turtle api",
                    teamName: "turtle team",
                    token: Token(value: "turtle token value")
                )

                mockTeamPipelinesService = MockTeamPipelinesService()
                subject.teamPipelinesService = mockTeamPipelinesService

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                it("sets the title") {
                    expect(subject.title).to(equal("Pipelines"))
                }

                it("sets itself as the data source for its table view") {
                    expect(subject.teamPipelinesTableView?.dataSource).to(beIdenticalTo(subject))
                }

                it("sets itself as the delegate for its table view") {
                    expect(subject.teamPipelinesTableView?.delegate).to(beIdenticalTo(subject))
                }

                it("asks the TeamPipelinesService to fetch the target team's pipelines") {
                    let expectedTarget = Target(name: "turtle target",
                           api: "turtle api",
                           teamName: "turtle team",
                           token: Token(value: "turtle token value")
                    )

                    expect(mockTeamPipelinesService.capturedTarget).to(equal(expectedTarget))
                }

                it("always has one section in the table view") {
                    expect(subject.numberOfSections(in: subject.teamPipelinesTableView!)).to(equal(1))
                }

                describe("Tapping the 'Logout' navigation item") {
                    beforeEach {
                        try! subject.logoutBarButtonItem?.tap()
                    }

                    it("asks its KeychainWrapper to delete its target") {
                        expect(mockKeychainWrapper.didCallDelete).to(beTrue())
                    }

                    it("sets the app to the concourse entry page") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockConcourseEntryViewController))
                    }
                }

                describe("When the pipelines service call resolves with a list of pipelines") {
                    beforeEach {
                        guard let completion = mockTeamPipelinesService.capturedCompletion else {
                            fail("Failed to pass a completion handler to the TeamPipelinesService")
                            return
                        }

                        let pipelineOne = Pipeline(name: "turtle pipeline one")
                        let pipelineTwo = Pipeline(name: "turtle pipeline two")
                        completion([pipelineOne, pipelineTwo], nil)
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("adds a row to the table for each of the pipelines returned") {
                        expect(subject.tableView(subject.teamPipelinesTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }

                    it("creates a cell in each of the rows for each of the pipelines returned") {
                        let cellOne = try! subject.teamPipelinesTableView!.fetchCell(at: IndexPath(row: 0, section: 0), asType: PipelineTableViewCell.self)
                        expect(cellOne.nameLabel?.text).to(equal("turtle pipeline one"))

                        let cellTwo = try! subject.teamPipelinesTableView!.fetchCell(at: IndexPath(row: 1, section: 0), asType: PipelineTableViewCell.self)
                        expect(cellTwo.nameLabel?.text).to(equal("turtle pipeline two"))
                    }

                    describe("Tapping one of the cells") {
                        beforeEach {
                            subject.tableView(subject.teamPipelinesTableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
                        }

                        it("sets up and presents the pipeline's builds page") {
                            func topmostViewControllerAsBuilds() -> BuildsViewController? {
                                return Fleet.getApplicationScreen()?.topmostViewController as? BuildsViewController
                            }

                            expect(topmostViewControllerAsBuilds()).toEventually(beIdenticalTo(mockBuildsViewController))
                            expect(topmostViewControllerAsBuilds()?.pipeline).toEventually(equal(Pipeline(name: "turtle pipeline one")))

                            let expectedTarget = Target(name: "turtle target",
                                                        api: "turtle api",
                                                        teamName: "turtle team",
                                                        token: Token(value: "turtle token value")
                            )
                            expect(topmostViewControllerAsBuilds()?.target).toEventually(equal(expectedTarget))
                        }
                    }
                }
            }
        }
    }
}
