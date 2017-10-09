import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class VisibilitySelectionViewControllerSpec: QuickSpec {
    override func spec() {
        describe("VisibilitySelectionViewController") {
            var subject: VisibilitySelectionViewController!

            var mockTeamsViewController: TeamsViewController!
            var mockPublicPipelinesViewController: PublicPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamsViewController = try! storyboard.mockIdentifier(TeamsViewController.storyboardIdentifier, usingMockFor: TeamsViewController.self)

                mockPublicPipelinesViewController = try! storyboard.mockIdentifier(PublicPipelinesViewController.storyboardIdentifier, usingMockFor: PublicPipelinesViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: VisibilitySelectionViewController.storyboardIdentifier) as! VisibilitySelectionViewController

                subject.concourseURLString = "concourseURLString"
            }

            describe("After the view loads") {
                var navigationController: UINavigationController!

                beforeEach {
                    navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                describe("Tapping the 'View public pipelines' button") {
                    beforeEach {
                        subject.viewPublicPipelinesButton?.tap()
                    }

                    it("disables the buttons") {
                        expect(subject.viewPublicPipelinesButton?.isEnabled).toEventually(beFalse())
                        expect(subject.logIntoTeamButton?.isEnabled).toEventually(beFalse())
                    }

                    it("presents the \(PublicPipelinesViewController.self)") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockPublicPipelinesViewController))
                        expect(mockPublicPipelinesViewController.concourseURLString).toEventually(equal("concourseURLString"))
                    }
                }

                describe("Tapping the 'Log in to a team button'") {
                    beforeEach {
                        subject.logIntoTeamButton?.tap()
                    }

                    it("presents the \(TeamsViewController.self)") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamsViewController))
                        expect(mockTeamsViewController.concourseURLString).toEventually(equal("concourseURLString"))
                    }
                }
            }
        }
    }
}
