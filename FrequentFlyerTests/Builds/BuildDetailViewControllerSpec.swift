import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class BuildDetailViewControllerSpec: QuickSpec {
    override func spec() {
        describe("BuildDetailViewController") {
            var subject: BuildDetailViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewControllerWithIdentifier(BuildDetailViewController.storyboardIdentifier) as! BuildDetailViewController

                let build = Build(id: 123,
                    jobName: "turtle job",
                    status: "turtle status",
                    pipelineName: "turtle pipeline"
                )

                subject.build = build
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }

                it("sets its title") {
                    expect(subject.title).to(equal("Build #123"))
                }

                it("sets the value for its pipeline label") {
                    expect(subject.pipelineValueLabel?.text).to(equal("turtle pipeline"))
                }

                it("sets the value for its job label") {
                    expect(subject.jobValueLabel?.text).to(equal("turtle job"))
                }

                it("sets the value for its status label") {
                    expect(subject.statusValueLabel?.text).to(equal("turtle status"))
                }
            }
        }
    }
}
