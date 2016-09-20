import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class TeamPipelinesViewControllerSpec: QuickSpec {
    class MockTeamPipelinesService: TeamPipelinesService {
        var capturedTarget: Target?
        var capturedCompletion: (([Pipeline]?, Error?) -> ())?

        override func getPipelines(forTarget target: Target, completion: (([Pipeline]?, Error?) -> ())?) {
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

    class MockBuildsViewController: BuildsViewController {
        override func viewDidLoad() { }
    }

    class MockConcourseEntryViewController: ConcourseEntryViewController {
        override func viewDidLoad() { }
    }

    override func spec() {
        describe("TeamPipelinesViewController"){
            var subject: TeamPipelinesViewController!
            var mockTeamPipelinesService: MockTeamPipelinesService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockBuildsViewController: MockBuildsViewController!
            var mockConcourseEntryViewController: MockConcourseEntryViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(TeamPipelinesViewController.storyboardIdentifier) as! TeamPipelinesViewController

                mockBuildsViewController = MockBuildsViewController()
                try! storyboard.bindViewController(mockBuildsViewController, toIdentifier: BuildsViewController.storyboardIdentifier)

                mockConcourseEntryViewController = MockConcourseEntryViewController()
                try! storyboard.bindViewController(mockConcourseEntryViewController, toIdentifier: ConcourseEntryViewController.storyboardIdentifier)

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
                    Fleet.setApplicationWindowRootViewController(navigationController)
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
                    expect(subject.numberOfSectionsInTableView(subject.teamPipelinesTableView!)).to(equal(1))
                }

                describe("Tapping the 'Logout' navigation item") {
                    beforeEach {
                        subject.logoutBarButtonItem?.tap()
                    }

                    it("asks its KeychainWrapper to delete its target") {
                        expect(mockKeychainWrapper.didCallDelete).to(beTrue())
                    }

                    it("sets the app to the concourse entry page") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockConcourseEntryViewController))
                    }

                    it("sets a UserTextInputPageOperator on the view controller") {
                        expect(mockConcourseEntryViewController.userTextInputPageOperator).toEventuallyNot(beNil())
                    }

                    it("sets an AuthMethodsService on the view controller") {
                        expect(mockConcourseEntryViewController.authMethodsService).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.authMethodsService?.httpClient).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.authMethodsService?.authMethodsDataDeserializer).toEventuallyNot(beNil())
                    }

                    it("sets an UnauthenticatedTokenService on the view controller") {
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService?.httpClient).toEventuallyNot(beNil())
                        expect(mockConcourseEntryViewController.unauthenticatedTokenService?.tokenDataDeserializer).toEventuallyNot(beNil())
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
                    }

                    it("adds a row to the table for each of the pipelines returned") {
                        expect(subject.tableView(subject.teamPipelinesTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }

                    it("creates a cell in each of the rows for each of the pipelines returned") {
                        let cellOne = subject.tableView(subject.teamPipelinesTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? PipelineTableViewCell
                        expect(cellOne).toNot(beNil())

                        guard let cellOneNameLabel = cellOne?.nameLabel else {
                            fail("Failed to pull the PipelineTableViewCell from the table")
                            return
                        }
                        expect(cellOneNameLabel.text).to(equal("turtle pipeline one"))

                        let cellTwo = subject.tableView(subject.teamPipelinesTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as?PipelineTableViewCell
                        expect(cellTwo).toNot(beNil())

                        guard let cellTwoNameLabel = cellTwo?.nameLabel else {
                            fail("Failed to pull the PipelineTableViewCell from the table")
                            return
                        }
                        expect(cellTwoNameLabel.text).to(equal("turtle pipeline two"))
                    }

                    describe("Tapping one of the cells") {
                        beforeEach {
                            subject.tableView(subject.teamPipelinesTableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        }

                        it("sets up and presents the pipeline's builds page") {
                            guard let buildsViewController = Fleet.getApplicationScreen()?.topmostViewController as? BuildsViewController else {
                                fail("Failed to present BuildsViewController")
                                return
                            }

                            expect(buildsViewController.pipeline).to(equal(Pipeline(name: "turtle pipeline one")))
                            let expectedTarget = Target(name: "turtle target",
                                                        api: "turtle api",
                                                        teamName: "turtle team",
                                                        token: Token(value: "turtle token value")
                            )
                            expect(buildsViewController.target).to(equal(expectedTarget))

                            guard let buildsService = buildsViewController.buildsService else {
                                fail("Failed to set a BuildsService on the BuildsViewController")
                                return
                            }

                            expect(buildsService.httpClient).toNot(beNil())
                            expect(buildsService.buildsDataDeserializer).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
