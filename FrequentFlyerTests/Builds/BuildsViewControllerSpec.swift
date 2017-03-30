import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class BuildsViewControllerSpec: QuickSpec {
    override func spec() {
        class MockBuildsService: BuildsService {
            var capturedTarget: Target?
            var capturedCompletion: (([Build]?, FFError?) -> ())?

            override func getBuilds(forTarget target: Target, completion: (([Build]?, Error?) -> ())?) {
                capturedTarget = target
                capturedCompletion = completion
            }
        }

        describe("BuildsViewController") {
            var subject: BuildsViewController!
            var mockBuildsService: MockBuildsService!

            var mockBuildDetailViewController: BuildDetailViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mockBuildDetailViewController = try! storyboard.mockIdentifier(BuildDetailViewController.storyboardIdentifier, usingMockFor: BuildDetailViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: BuildsViewController.storyboardIdentifier) as! BuildsViewController

                mockBuildsService = MockBuildsService()
                subject.buildsService = mockBuildsService

                let pipeline = Pipeline(name: "turtle pipeline")
                subject.pipeline = pipeline

                let target = Target(name: "turtle target", api: "turtle api", teamName: "turtle team", token: Token(value: "turtle token value")
                )
                subject.target = target
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                it("sets its title") {
                    expect(subject.title).to(equal("turtle pipeline"))
                }

                it("sets itself as the data source of its table view") {
                    expect(subject.buildsTableView?.dataSource).to(beIdenticalTo(subject))
                }

                it("sets itself as the delegate of its table view") {
                    expect(subject.buildsTableView?.delegate).to(beIdenticalTo(subject))
                }

                it("calls out to the BuildsService") {
                    let expectedTarget = Target(
                        name: "turtle target",
                        api: "turtle api",
                        teamName: "turtle team",
                        token: Token(value: "turtle token value")
                    )
                    expect(mockBuildsService.capturedTarget).to(equal(expectedTarget))
                }

                it("always has one section in its table view") {
                    expect(subject.numberOfSections(in: subject.buildsTableView!)).to(equal(1))
                }

                describe("The table view's header view") {
                    it("is a BuildsTableViewHeaderView") {
                        expect(subject.tableView(subject.buildsTableView!, viewForHeaderInSection: 0)).to(beAKindOf(BuildsTableViewHeaderView.self))
                    }
                }

                describe("When the BuildsService call resolves with some builds") {
                    beforeEach {
                        guard let completion = mockBuildsService.capturedCompletion else {
                            fail("Failed to call BuildsService with a completion handler")
                            return
                        }

                        let buildOne = Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job", status: "turtle last status", pipelineName: "turtle pipeline")
                        let buildTwo = Build(id: 2, name: "name", teamName: "team name", jobName: "crab job", status: "crab last status", pipelineName: "crab pipeline")
                        let buildThree = Build(id: 1, name: "name", teamName: "team name", jobName: "other turtle job", status: "turtle last status", pipelineName: "turtle pipeline")
                        completion([buildOne, buildTwo, buildThree], nil)
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("inserts a row for each build with correct pipeline name returned by the service") {
                        expect(subject.tableView(subject.buildsTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }

                    it("creates a cell in each row for each build with correct pipeline name returned by the service") {
                        let cellOneOpt = subject.tableView(subject.buildsTableView!, cellForRowAt: IndexPath(row: 0, section: 0)) as? BuildTableViewCell
                        guard let cellOne = cellOneOpt else {
                            fail("Failed to fetch a BuildTableViewCell")
                            return
                        }
                        expect(cellOne.idLabel?.text).to(equal("3"))
                        expect(cellOne.jobNameLabel?.text).to(equal("turtle job"))
                        expect(cellOne.statusLabel?.text).to(equal("turtle last status"))

                        let cellTwoOpt = subject.tableView(subject.buildsTableView!, cellForRowAt: IndexPath(row: 1, section: 0)) as? BuildTableViewCell
                        guard let cellTwo = cellTwoOpt else {
                            fail("Failed to fetch a BuildTableViewCell")
                            return
                        }
                        expect(cellTwo.idLabel?.text).to(equal("1"))
                        expect(cellTwo.jobNameLabel?.text).to(equal("other turtle job"))
                        expect(cellTwo.statusLabel?.text).to(equal("turtle last status"))
                    }

                    describe("Tapping on a cell") {
                        beforeEach {
                            subject.tableView(subject.buildsTableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
                        }

                        it("displays a detail page for the build associated with the selected row") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockBuildDetailViewController))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? BuildDetailViewController)?.build).toEventually(equal(Build(id: 3, name: "name", teamName: "team name", jobName: "turtle job", status: "turtle last status", pipelineName: "turtle pipeline")))

                            let expectedBuild = Build(
                                id: 3,
                                name: "name",
                                teamName: "team name",
                                jobName: "turtle job",
                                status: "turtle last status",
                                pipelineName: "turtle pipeline"
                            )

                            expect((Fleet.getApplicationScreen()?.topmostViewController as? BuildDetailViewController)?.build).toEventually(equal(expectedBuild))

                            let expectedTarget = Target(name: "turtle target", api: "turtle api", teamName: "turtle team", token: Token(value: "turtle token value")
                            )
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? BuildDetailViewController)?.target).toEventually(equal(expectedTarget))
                        }
                    }
                }
            }
        }
    }
}
