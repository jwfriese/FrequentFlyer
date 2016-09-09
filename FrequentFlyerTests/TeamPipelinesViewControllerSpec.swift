import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class TeamPipelinesViewControllerSpec: QuickSpec {
    override func spec() {
        class MockTeamPipelinesService: TeamPipelinesService {
            var capturedTarget: Target?
            var capturedCompletion: (([Pipeline]?, Error?) -> ())?
            
            override func getPipelines(forTarget target: Target, completion: (([Pipeline]?, Error?) -> ())?) {
                capturedTarget = target
                capturedCompletion = completion
            }
        }
        
        describe("TeamPipelinesViewController"){
            var subject: TeamPipelinesViewController!
            var mockTeamPipelinesService: MockTeamPipelinesService!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(TeamPipelinesViewController.storyboardIdentifier) as! TeamPipelinesViewController
                
                subject.target = Target(name: "turtle target",
                    api: "turtle api",
                    teamName: "turtle team",
                    token: Token(value: "turtle token value")
                )
                
                mockTeamPipelinesService = MockTeamPipelinesService()
                subject.teamPipelinesService = mockTeamPipelinesService
            }
            
            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }
                
                it("sets the title") {
                    expect(subject.title).to(equal("turtle target Pipelines"))
                }
                
                it("sets itself as the data source for its table view") {
                    expect(subject.teamPipelinesTableView?.dataSource).to(beIdenticalTo(subject))
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
                }
            }
        }
    }
}
