import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class TargetListViewControllerSpec: QuickSpec {
    class MockTargetListService: TargetListService {
        override func getTargetList() -> [Target] {
            return [
                Target(name: "turtle target one", api: "turtle api", teamName: "turtle team", token: Token(value: "val")),
                Target(name: "turtle target two", api: "turtle api", teamName: "turtle team", token: Token(value: "val"))
            ]
        }
    }

    override func spec() {
        describe("TargetListViewController") {
            var subject: TargetListViewController!
            var mockTargetListService: MockTargetListService!

            var navigationController: UINavigationController!
            var mockAddTargetViewController: AddTargetViewController!
            var mockTeamPipelinesViewController: TeamPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockAddTargetViewController = AddTargetViewController()
                try! storyboard.bindViewController(mockAddTargetViewController, toIdentifier: AddTargetViewController.storyboardIdentifier)

                mockTeamPipelinesViewController = TeamPipelinesViewController()
                try! storyboard.bindViewController(mockTeamPipelinesViewController, toIdentifier: TeamPipelinesViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(TargetListViewController.storyboardIdentifier) as! TargetListViewController

                mockTargetListService = MockTargetListService()
                subject.targetListService = mockTargetListService

                navigationController = UINavigationController(rootViewController: subject)
                Fleet.setApplicationWindowRootViewController(navigationController)
            }

            describe("After the view has loaded") {
                beforeEach {
                    subject.view
                }

                it("has a title") {
                    expect(subject.title).to(equal("Targets"))
                }

                it("sets itself as its table view's data source") {
                    expect(subject.targetListTableView?.dataSource).to(beIdenticalTo(subject))
                }

                it("sets itself as its table view's delegate") {
                    expect(subject.targetListTableView?.delegate).to(beIdenticalTo(subject))
                }

                it("only has one section") {
                    expect(subject.numberOfSectionsInTableView(subject.targetListTableView!)).to(equal(1))
                }

                it("has a row for each target that the TargetListService provides") {
                    expect(subject.tableView(subject.targetListTableView!, numberOfRowsInSection:0)).to(equal(2))
                }

                it("has a cell for each target in each row") {
                    let cellOne = subject.tableView(subject.targetListTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? TargetListTableViewCell
                    expect(cellOne).toNot(beNil())

                    guard let cellOneTargetNameLabel = cellOne?.targetNameLabel else {
                        fail("Did not pull TargetListTableViewCell from table view")
                        return
                    }
                    expect(cellOneTargetNameLabel.text).to(equal("turtle target one"))

                    let cellTwo = subject.tableView(subject.targetListTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? TargetListTableViewCell
                    expect(cellTwo).toNot(beNil())

                    guard let cellTwoTargetNameLabel = cellTwo?.targetNameLabel else {
                        fail("Did not pull TargetListTableViewCell from table view")
                        return
                    }
                    expect(cellTwoTargetNameLabel.text).to(equal("turtle target two"))
                }

                describe("Tapping on one of the cells") {
                    beforeEach {
                        subject.tableView(subject.targetListTableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    }

                    it("presents the builds page for that target") {
                        expect(navigationController.topViewController).to(beIdenticalTo(mockTeamPipelinesViewController))
                        expect(mockTeamPipelinesViewController.target).to(equal(Target(name: "turtle target one", api: "turtle api", teamName: "turtle team", token: Token(value: "val"))))
                    }

                    it("sets a TeamPipelinesService on the controller") {
                        guard let teamPipelinesService = mockTeamPipelinesViewController.teamPipelinesService else {
                            fail("Failed to set TeamPipelinesService on TeamPipelinesViewController")
                            return
                        }

                        expect(teamPipelinesService.httpClient).toNot(beNil())
                        expect(teamPipelinesService.pipelineDataDeserializer).toNot(beNil())
                    }
                }

                describe("Tapping the 'Add Target' bar button") {
                    beforeEach {
                        let rightBarButton = subject.navigationItem.rightBarButtonItem!
                        rightBarButton.tap()
                    }

                    it("takes the user to the Add Target page") {
                        expect(navigationController.topViewController).to(beIdenticalTo(mockAddTargetViewController))
                    }

                    it("sets itself as the AddTargetDelegate on the presented page") {
                        expect(mockAddTargetViewController.addTargetDelegate).to(beIdenticalTo(subject))
                    }

                    it("sets an UnauthenticatedTokenService on the controller") {
                        guard let unauthenticatedTokenService = mockAddTargetViewController.unauthenticatedTokenService else {
                            fail("Failed to set a UnauthenticatedTokenService on the AddTargetViewController")
                            return
                        }

                        expect(unauthenticatedTokenService.httpClient).toNot(beNil())
                        expect(unauthenticatedTokenService.tokenDataDeserializer).toNot(beNil())
                    }

                    it("sets a AuthMethodsService on the controller") {
                        guard let authMethodsService = mockAddTargetViewController.authMethodsService else {
                            fail("Failed to set a AuthMethodsService on the AddTargetViewController")
                            return
                        }

                        expect(authMethodsService.httpClient).toNot(beNil())
                        expect(authMethodsService.authMethodsDataDeserializer).toNot(beNil())
                    }

                    describe("Handling addition of a target") {
                        var addedTarget: Target!

                        beforeEach {
                            addedTarget = Target(name: "new turtle target", api: "new turtle api", teamName: "new turtle team name", token: Token(value: "new turtle token value"))
                            subject.onTargetAdded(addedTarget)
                        }

                        it("dismisses the presented view controller") {
                            expect(navigationController.topViewController).toEventually(beIdenticalTo(subject))
                        }

                        it("adds an additional row") {
                            expect(subject.tableView(subject.targetListTableView!, numberOfRowsInSection:0)).to(equal(3))
                        }

                        it("adds another cell for the added target") {
                            let newCell = subject.tableView(subject.targetListTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as? TargetListTableViewCell
                            expect(newCell).toNot(beNil())
                            guard let cellTwoTargetNameLabel = newCell?.targetNameLabel else {
                                fail("Did not pull TargetListTableViewCell from table view")
                                return
                            }
                            expect(cellTwoTargetNameLabel.text).to(equal("new turtle target"))
                        }
                    }
                }
            }
        }
    }
}
