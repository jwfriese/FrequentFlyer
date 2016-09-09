import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class BuildsViewControllerSpec: QuickSpec {
    override func spec() {
        class MockBuildsService: BuildsService {
            var capturedTarget: Target?
            var capturedCompletion: (([Build]?, Error?) -> ())?
            
            override func getBuilds(forTarget target: Target, completion: (([Build]?, Error?) -> ())?) {
                capturedTarget = target
                capturedCompletion = completion
            }
        }
        
        describe("BuildsViewController") {
            var subject: BuildsViewController!
            var mockBuildsService: MockBuildsService!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(BuildsViewController.storyboardIdentifier) as! BuildsViewController
                
                mockBuildsService = MockBuildsService()
                subject.buildsService = mockBuildsService
                
                let pipeline = Pipeline(name: "turtle pipeline")
                subject.pipeline = pipeline
                
                let target = Target(name: "turtle target", api: "turtle api", teamName: "turtle team", token: Token(value: "turtle token value"))
                subject.target = target
            }
            
            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }
                
                it("sets its title") {
                    expect(subject.title).to(equal("turtle pipeline Builds"))
                }
                
                it("sets itself as the data source of its table view") {
                    expect(subject.buildsTableView?.dataSource).to(beIdenticalTo(subject))
                }
                
                it("sets itself as the delegate of its table view") {
                    expect(subject.buildsTableView?.delegate).to(beIdenticalTo(subject))
                }
                
                it("calls out to the BuildsService") {
                    let expectedTarget = Target(name: "turtle target",
                                                api: "turtle api",
                                                teamName: "turtle team",
                                                token: Token(value: "turtle token value")
                    )
                    expect(mockBuildsService.capturedTarget).to(equal(expectedTarget))
                }
                
                it("always has one section in its table view") {
                    expect(subject.numberOfSectionsInTableView(subject.buildsTableView!)).to(equal(1))
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
                        
                        let buildOne = Build(id: 2, jobName: "turtle job", status: "turtle last status", pipelineName: "turtle pipeline name")
                        let buildTwo = Build(id: 1, jobName: "crab job", status: "crab last status", pipelineName: "crab pipeline name")
                        completion([buildOne, buildTwo], nil)
                    }
                    
                    it("inserts a row for each build returned by the service") {
                        expect(subject.tableView(subject.buildsTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }
                    
                    it("creates a cell in each row for each build returned by the service") {
                        let cellOneOpt = subject.tableView(subject.buildsTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? BuildTableViewCell
                        guard let cellOne = cellOneOpt else {
                            fail("Failed to fetch a BuildTableViewCell")
                            return
                        }
                        expect(cellOne.idLabel?.text).to(equal("2"))
                        expect(cellOne.jobNameLabel?.text).to(equal("turtle job"))
                        expect(cellOne.statusLabel?.text).to(equal("turtle last status"))
                        
                        let cellTwoOpt = subject.tableView(subject.buildsTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? BuildTableViewCell
                        guard let cellTwo = cellTwoOpt else {
                            fail("Failed to fetch a BuildTableViewCell")
                            return
                        }
                        expect(cellTwo.idLabel?.text).to(equal("1"))
                        expect(cellTwo.jobNameLabel?.text).to(equal("crab job"))
                        expect(cellTwo.statusLabel?.text).to(equal("crab last status"))
                    }
                }
            }
        }
    }
}
