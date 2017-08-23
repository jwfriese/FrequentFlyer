import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class PublicPipelinesViewControllerSpec: QuickSpec {
    class MockPublicPipelinesDataStreamProducer: PublicPipelinesDataStreamProducer {
        var pipelinesGroupsSubject = PublishSubject<[PipelineGroupSection]>()
        var capturedConcourseURL: String?

        override func openStream(forConcourseWithURL concourseURL: String) -> Observable<[PipelineGroupSection]> {
            capturedConcourseURL = concourseURL
            return pipelinesGroupsSubject
        }
    }

    class MockTeamListService: TeamListService {
        var capturedConcourseURL: String?
        var teamListSubject = PublishSubject<[String]>()

        override func getTeams(forConcourseWithURL concourseURL: String) -> Observable<[String]> {
            capturedConcourseURL = concourseURL
            return teamListSubject
        }
    }

    override func spec() {
        describe("PublicPipelinesViewController"){
            var subject: PublicPipelinesViewController!
            var mockPublicPipelinesDataStreamProducer: MockPublicPipelinesDataStreamProducer!
            var mockTeamListService: MockTeamListService!

            var mockTeamsViewController: TeamsViewController!
            var mockConcourseEntryViewController: ConcourseEntryViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: PublicPipelinesViewController.storyboardIdentifier) as! PublicPipelinesViewController

                mockTeamsViewController = try! storyboard.mockIdentifier(TeamsViewController.storyboardIdentifier, usingMockFor: TeamsViewController.self)
                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

                subject.concourseURLString = "concourseURL"

                mockPublicPipelinesDataStreamProducer = MockPublicPipelinesDataStreamProducer()
                subject.publicPipelinesDataStreamProducer = mockPublicPipelinesDataStreamProducer

                mockTeamListService = MockTeamListService()
                subject.teamListService = mockTeamListService
            }

            describe("After the view has loaded") {
                beforeEach {
                    _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).to(equal("Pipelines"))
                }

                it("sets the data source as the delegate of the table view") {
                    expect(subject.pipelinesTableView?.rx.delegate.forwardToDelegate()).toEventually(beIdenticalTo(subject.publicPipelinesTableViewDataSource))
                }

                it("opens the data stream") {
                    expect(mockPublicPipelinesDataStreamProducer.capturedConcourseURL).to(equal("concourseURL"))
                }

                it("has an active loading indicator") {
                    expect(subject.loadingIndicator?.isAnimating).toEventually(beTrue())
                    expect(subject.loadingIndicator?.isHidden).toEventually(beFalse())
                }

                it("hides the table views row lines while there is no content") {
                    expect(subject.pipelinesTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.none))
                }

                describe("Tapping the gear in the navigation item") {
                    beforeEach {
                        try! subject.gearBarButtonItem?.tap()
                    }

                    it("displays an action sheet with the 'Log Into a Team' option") {
                        let actionSheet: () -> UIAlertController? = {
                            return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                        }

                        expect(actionSheet()).toEventuallyNot(beNil())
                    }

                    describe("Tapping the 'Log Into a Team' button in the action sheet") {
                        // This will not be here next commit
//                        it("makes a call to the team list service") {
//                            expect(mockTeamListService.capturedConcourseURL).toEventually(equal("concourseURL"))
//                        }
                    }

                    describe("Tapping the 'Select a Concourse' button in the action sheet") {
                        it("sends the app to the \(ConcourseEntryViewController.self)") {
                            let actionSheet: () -> UIAlertController? = {
                                return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                            }

                            var actionSheetDidAppear = false
                            var didAttemptSelectAConcourseTap = false
                            let assertDidBeginSelectingAConcourse: () -> Bool = {
                                if !actionSheetDidAppear {
                                    if actionSheet() != nil {
                                        actionSheetDidAppear = true
                                    }

                                    return false
                                }

                                if !didAttemptSelectAConcourseTap {
                                    try! actionSheet()!.tapAlertAction(withTitle: "Select a Concourse")
                                    didAttemptSelectAConcourseTap = true
                                    return false
                                }

                                return Fleet.getApplicationScreen()?.topmostViewController === mockConcourseEntryViewController
                            }

                            expect(assertDidBeginSelectingAConcourse()).toEventually(beTrue())
                        }
                    }

                    describe("Tapping the 'Cancel' button in the action sheet") {
                        it("dismisses the action sheet") {
                            let actionSheet: () -> UIAlertController? = {
                                return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                            }

                            var actionSheetDidAppear = false
                            var didAttemptLogOutTap = false
                            let assertDidDismissActionSheet: () -> Bool = {
                                if !actionSheetDidAppear {
                                    if actionSheet() != nil {
                                        actionSheetDidAppear = true
                                    }

                                    return false
                                }

                                if !didAttemptLogOutTap {
                                    try! actionSheet()!.tapAlertAction(withTitle: "Cancel")
                                    didAttemptLogOutTap = true
                                    return false
                                }

                                return Fleet.getApplicationScreen()?.topmostViewController === subject
                            }

                            expect(assertDidDismissActionSheet()).toEventually(beTrue())
                        }
                    }
                }

                describe("When the public pipelines data stream spits out some pipelines") {
                    beforeEach {
                        let pipelineOne = Pipeline(name: "pipeline one", isPublic: true, teamName: "cat")
                        let pipelineTwo = Pipeline(name: "pipeline two", isPublic: true, teamName: "turtle")
                        let pipelineThree = Pipeline(name: "pipeline three", isPublic: true, teamName: "dog")

                        var catSection = PipelineGroupSection()
                        catSection.items.append(pipelineOne)
                        var turtleSection = PipelineGroupSection()
                        turtleSection.items.append(pipelineTwo)
                        var dogSection = PipelineGroupSection()
                        dogSection.items.append(pipelineThree)
                        mockPublicPipelinesDataStreamProducer.pipelinesGroupsSubject.onNext([catSection, turtleSection, dogSection])
                        mockPublicPipelinesDataStreamProducer.pipelinesGroupsSubject.onCompleted()
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.pipelinesTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("adds a row to the table for each of the pipelines returned") {
//                        expect(subject.pipelinesTableView).to(equal(2))

                    }

                    it("creates a cell in each of the rows for each of the pipelines returned") {
                        let cellOne = try! subject.pipelinesTableView!.fetchCell(at: IndexPath(row: 0, section: 0), asType: PipelineTableViewCell.self)
                        expect(cellOne.nameLabel?.text).to(equal("pipeline one"))

                        let cellTwo = try! subject.pipelinesTableView!.fetchCell(at: IndexPath(row: 0, section: 1), asType: PipelineTableViewCell.self)
                        expect(cellTwo.nameLabel?.text).to(equal("pipeline two"))
                    }
                }

                describe("When the public pipelines data stream emits an error") {
                    beforeEach {
                        mockPublicPipelinesDataStreamProducer.pipelinesGroupsSubject.onError(UnexpectedError(""))
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.pipelinesTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("presents an alert describing the error") {
                        let alert: () -> UIAlertController? = {
                            return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                        }

                        expect(alert()).toEventuallyNot(beNil())
                        expect(alert()?.title).toEventually(equal("Error"))
                        expect(alert()?.message).toEventually(equal("An unexpected error has occurred. Please try again."))
                    }

                    describe("Tapping the 'OK' button on the alert") {
                        it("dismisses the alert") {
                            let screen = Fleet.getApplicationScreen()
                            var didTapOK = false
                            let assertOKTappedBehavior = { () -> Bool in
                                if didTapOK {
                                    return screen?.topmostViewController === subject
                                }

                                if let alert = screen?.topmostViewController as? UIAlertController {
                                    try! alert.tapAlertAction(withTitle: "OK")
                                    didTapOK = true
                                }

                                return false
                            }

                            expect(assertOKTappedBehavior()).toEventually(beTrue())
                        }
                    }
                }
            }
        }
    }
}
