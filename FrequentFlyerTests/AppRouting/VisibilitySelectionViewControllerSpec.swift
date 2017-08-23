import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class VisibilitySelectionViewControllerSpec: QuickSpec {
    class MockTeamListService: TeamListService {
        var capturedConcourseURL: String?
        var teamListSubject = PublishSubject<[String]>()

        override func getTeams(forConcourseWithURL concourseURL: String) -> Observable<[String]> {
            capturedConcourseURL = concourseURL
            return teamListSubject
        }
    }

    override func spec() {
        describe("VisibilitySelectionViewController") {
            var subject: VisibilitySelectionViewController!
            var mockTeamListService: MockTeamListService!

            var mockTeamsViewController: TeamsViewController!
            var mockPublicPipelinesViewController: PublicPipelinesViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockTeamsViewController = try! storyboard.mockIdentifier(TeamsViewController.storyboardIdentifier, usingMockFor: TeamsViewController.self)

                mockPublicPipelinesViewController = try! storyboard.mockIdentifier(PublicPipelinesViewController.storyboardIdentifier, usingMockFor: PublicPipelinesViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: VisibilitySelectionViewController.storyboardIdentifier) as! VisibilitySelectionViewController

                mockTeamListService = MockTeamListService()
                subject.teamListService = mockTeamListService

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
                        try! subject.viewPublicPipelinesButton?.tap()
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
                        try! subject.logIntoTeamButton?.tap()
                    }

                    it("makes a call to the team list service") {
                        expect(mockTeamListService.capturedConcourseURL).to(equal("concourseURLString"))
                    }

                    it("disables the buttons") {
                        expect(subject.viewPublicPipelinesButton?.isEnabled).toEventually(beFalse())
                        expect(subject.logIntoTeamButton?.isEnabled).toEventually(beFalse())
                    }

                    describe("When the team list service call resolves with some team names") {
                        beforeEach {
                            mockTeamListService.teamListSubject.onNext(["turtle_team", "crab_team", "puppy_team"])
                            mockTeamListService.teamListSubject.onCompleted()
                        }

                        it("presents the \(TeamsViewController.self)") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockTeamsViewController))
                            expect(mockTeamsViewController.concourseURLString).toEventually(equal("concourseURLString"))
                            expect(mockTeamsViewController.teams).toEventually(equal(["turtle_team", "crab_team", "puppy_team"]))
                        }
                    }

                    describe("When the team list service call resolves with no teams") {
                        beforeEach {
                            mockTeamListService.teamListSubject.onNext([])
                            mockTeamListService.teamListSubject.onCompleted()
                        }

                        it("presents an alert informing the user that there appear to be no teams") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("No Teams"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not find any teams for this Concourse instance."))
                        }

                        it("enables the buttons") {
                            expect(subject.viewPublicPipelinesButton?.isEnabled).toEventually(beTrue())
                            expect(subject.logIntoTeamButton?.isEnabled).toEventually(beTrue())
                        }
                    }

                    describe("When the team list service call resolves with an error") {
                        beforeEach {
                            mockTeamListService.teamListSubject.onError(BasicError(details: ""))
                            mockTeamListService.teamListSubject.onCompleted()
                        }

                        it("presents an alert informing the user of the build that was triggered") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Error"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not connect to a Concourse at the given URL."))
                        }

                        it("enables the buttons") {
                            expect(subject.viewPublicPipelinesButton?.isEnabled).toEventually(beTrue())
                            expect(subject.logIntoTeamButton?.isEnabled).toEventually(beTrue())
                        }
                    }
                }
            }
        }
    }
}
