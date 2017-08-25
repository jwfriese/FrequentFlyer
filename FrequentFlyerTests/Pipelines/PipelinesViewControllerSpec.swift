import XCTest
import Quick
import Nimble
import Fleet
import RxSwift
@testable import FrequentFlyer

class PipelinesViewControllerSpec: QuickSpec {
    class MockPipelinesService: PipelinesService {
        var capturedTarget: Target?
        var publishSubject = PublishSubject<[Pipeline]>()

        override func getPipelines(forTarget target: Target) -> Observable<[Pipeline]> {
            capturedTarget = target
            return publishSubject
        }
    }

    class MockKeychainWrapper: KeychainWrapper {
        var didCallDelete = false

        override func deleteTarget() {
            didCallDelete = true
        }
    }

    override func spec() {
        describe("PipelinesViewController"){
            var subject: PipelinesViewController!
            var mockPipelinesService: MockPipelinesService!
            var mockKeychainWrapper: MockKeychainWrapper!

            var mockJobsViewController: JobsViewController!
            var mockConcourseEntryViewController: ConcourseEntryViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: PipelinesViewController.storyboardIdentifier) as! PipelinesViewController

                mockJobsViewController = try! storyboard.mockIdentifier(JobsViewController.storyboardIdentifier, usingMockFor: JobsViewController.self)
                mockConcourseEntryViewController = try! storyboard.mockIdentifier(ConcourseEntryViewController.storyboardIdentifier, usingMockFor: ConcourseEntryViewController.self)

                subject.target = Target(name: "turtle target",
                    api: "turtle api",
                    teamName: "turtle team",
                    token: Token(value: "turtle token value")
                )

                mockPipelinesService = MockPipelinesService()
                subject.pipelinesService = mockPipelinesService

                mockKeychainWrapper = MockKeychainWrapper()
                subject.keychainWrapper = mockKeychainWrapper
            }

            describe("After the view has loaded") {
                var navigationController: UINavigationController!

                beforeEach {
                    navigationController = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).to(equal("Pipelines"))
                }

                it("sets itself as the data source for its table view") {
                    expect(subject.pipelinesTableView?.dataSource).to(beIdenticalTo(subject))
                }

                it("sets itself as the delegate for its table view") {
                    expect(subject.pipelinesTableView?.delegate).to(beIdenticalTo(subject))
                }

                it("asks the PipelinesService to fetch the target team's pipelines") {
                    let expectedTarget = Target(name: "turtle target",
                           api: "turtle api",
                           teamName: "turtle team",
                           token: Token(value: "turtle token value")
                    )

                    expect(mockPipelinesService.capturedTarget).to(equal(expectedTarget))
                }

                it("always has one section in the table view") {
                    expect(subject.numberOfSections(in: subject.pipelinesTableView!)).to(equal(1))
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

                    it("displays an action sheet with the 'Log Out' option") {
                        let actionSheet: () -> UIAlertController? = {
                            return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                        }

                        expect(actionSheet()).toEventuallyNot(beNil())
                    }

                    describe("Tapping the 'Log Out' button in the action sheet") {
                        it("sets the app to the concourse entry page") {
                            let actionSheet: () -> UIAlertController? = {
                                return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                            }

                            var actionSheetDidAppear = false
                            var didAttemptLogOutTap = false
                            let assertDidLogOut: () -> Bool = {
                                if !actionSheetDidAppear {
                                    if actionSheet() != nil {
                                        actionSheetDidAppear = true
                                    }

                                    return false
                                }

                                if !didAttemptLogOutTap {
                                    try! actionSheet()!.tapAlertAction(withTitle: "Log Out")
                                    didAttemptLogOutTap = true
                                    return false
                                }

                                return Fleet.getApplicationScreen()?.topmostViewController === mockConcourseEntryViewController
                            }

                            expect(assertDidLogOut()).toEventually(beTrue())
                        }

                        it("asks its KeychainWrapper to delete its target") {
                            let actionSheet: () -> UIAlertController? = {
                                return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                            }

                            var actionSheetDidAppear = false
                            var didAttemptLogOutTap = false
                            let assertDidDeleteFromKeychain: () -> Bool = {
                                if !actionSheetDidAppear {
                                    if actionSheet() != nil {
                                        actionSheetDidAppear = true
                                    }

                                    return false
                                }

                                if !didAttemptLogOutTap {
                                    try! actionSheet()!.tapAlertAction(withTitle: "Log Out")
                                    didAttemptLogOutTap = true
                                    return false
                                }

                                return mockKeychainWrapper.didCallDelete
                            }

                            expect(assertDidDeleteFromKeychain()).toEventually(beTrue())
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

                describe("When the pipelines service call resolves with a list of pipelines") {
                    beforeEach {
                        let pipelineOne = Pipeline(name: "turtle pipeline one", isPublic: false, teamName: "")
                        let pipelineTwo = Pipeline(name: "turtle pipeline two", isPublic: false, teamName: "")
                        mockPipelinesService.publishSubject.onNext([pipelineOne, pipelineTwo])
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
                        expect(subject.tableView(subject.pipelinesTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }

                    it("creates a cell in each of the rows for each of the pipelines returned") {
                        let cellOne = try! subject.pipelinesTableView!.fetchCell(at: IndexPath(row: 0, section: 0), asType: PipelineTableViewCell.self)
                        expect(cellOne.nameLabel?.text).to(equal("turtle pipeline one"))

                        let cellTwo = try! subject.pipelinesTableView!.fetchCell(at: IndexPath(row: 1, section: 0), asType: PipelineTableViewCell.self)
                        expect(cellTwo.nameLabel?.text).to(equal("turtle pipeline two"))
                    }

                    describe("Tapping one of the cells") {
                        beforeEach {
                            try! subject.pipelinesTableView!.selectRow(at: IndexPath(row: 0, section: 0))
                        }

                        it("sets up and presents the pipeline's jobs page") {
                            func jobsViewController() -> JobsViewController? {
                                return Fleet.getApplicationScreen()?.topmostViewController as? JobsViewController
                            }

                            expect(jobsViewController()).toEventually(beIdenticalTo(mockJobsViewController))
                            expect(jobsViewController()?.pipeline).toEventually(equal(Pipeline(name: "turtle pipeline one", isPublic: false, teamName: "")))
                            expect(jobsViewController()?.dataStream).toEventually(beAKindOf(AuthorizedJobsDataStream.self))

                            let expectedTarget = Target(name: "turtle target",
                                                        api: "turtle api",
                                                        teamName: "turtle team",
                                                        token: Token(value: "turtle token value")
                            )
                            expect((jobsViewController()?.dataStream as? AuthorizedJobsDataStream)?.target).toEventually(equal(expectedTarget))
                            expect(jobsViewController()?.target).toEventually(equal(expectedTarget))
                        }

                        it("immediately deselects the cell") {
                            let selectedCell = subject.pipelinesTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                            expect(selectedCell).toEventuallyNot(beNil())
                            expect(selectedCell?.isHighlighted).toEventually(beFalse())
                            expect(selectedCell?.isSelected).toEventually(beFalse())
                        }
                    }
                }

                describe("When the pipelines service call resolves with an 'Unauthorized' response") {
                    beforeEach {
                        mockPipelinesService.publishSubject.onError(AuthorizationError())
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.pipelinesTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("presents an alert describing the authorization error") {
                        let alert: () -> UIAlertController? = {
                            return Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController
                        }

                        expect(alert()).toEventuallyNot(beNil())
                        expect(alert()?.title).toEventually(equal("Unauthorized"))
                        expect(alert()?.message).toEventually(equal("Your credentials have expired. Please authenticate again."))
                    }

                    describe("Tapping the 'Log Out' button on the alert") {
                        it("pops itself back to the initial page") {
                            let screen = Fleet.getApplicationScreen()
                            var didTapLogOut = false
                            let assertLogOutTappedBehavior = { () -> Bool in
                                if didTapLogOut {
                                    return screen?.topmostViewController === mockConcourseEntryViewController
                                }

                                if let alert = screen?.topmostViewController as? UIAlertController {
                                    try! alert.tapAlertAction(withTitle: "Log Out")
                                    didTapLogOut = true
                                }

                                return false
                            }

                            expect(assertLogOutTappedBehavior()).toEventually(beTrue())
                        }
                    }
                }

                describe("When the pipelines service call resolves with an unexpected error") {
                    beforeEach {
                        mockPipelinesService.publishSubject.onError(UnexpectedError(""))
                        RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
                    }

                    it("stops and hides the loading indicator") {
                        expect(subject.loadingIndicator?.isAnimating).toEventually(beFalse())
                        expect(subject.loadingIndicator?.isHidden).toEventually(beTrue())
                    }

                    it("shows the table views row lines") {
                        expect(subject.pipelinesTableView?.separatorStyle).toEventually(equal(UITableViewCellSeparatorStyle.singleLine))
                    }

                    it("presents an alert describing the authorization error") {
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
