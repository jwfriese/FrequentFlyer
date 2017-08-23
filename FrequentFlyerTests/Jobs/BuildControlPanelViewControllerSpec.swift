import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class BuildControlPanelViewControllerSpec: QuickSpec {
    override func spec() {
        class MockTriggerBuildService: TriggerBuildService {
            var capturedTarget: Target?
            var capturedJobName: String?
            var capturedPipelineName: String?
            var triggeredBuildSubject = PublishSubject<Build>()

            override func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String) -> Observable<Build> {
                capturedTarget = target
                capturedJobName = jobName
                capturedPipelineName = pipelineName

                return triggeredBuildSubject
            }
        }

        class MockElapsedTimePrinter: ElapsedTimePrinter {
            var capturedTime: TimeInterval?
            var toReturnResult = ""

            override func printTime(since timePassedInSeconds: TimeInterval?) -> String {
                capturedTime = timePassedInSeconds
                return toReturnResult
            }
        }

        describe("BuildControlPanelViewController") {
            var subject: BuildControlPanelViewController!
            var mockTriggerBuildService: MockTriggerBuildService!
            var mockElapsedTimePrinter: MockElapsedTimePrinter!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                subject = storyboard.instantiateViewController(withIdentifier: BuildControlPanelViewController.storyboardIdentifier) as? BuildControlPanelViewController

                mockTriggerBuildService = MockTriggerBuildService()
                subject.triggerBuildService = mockTriggerBuildService

                let target = Target(name: "turtle target",
                                    api: "turtle api",
                                    teamName: "turtle team name",
                                    token: Token(value: "turtle token value")
                )

                subject.target = target

                subject.pipeline = Pipeline(name: "pipeline_name", isPublic: false, teamName: "")

                mockElapsedTimePrinter = MockElapsedTimePrinter()
                subject.elapsedTimePrinter = mockElapsedTimePrinter
            }

            describe("After the view loads") {
                beforeEach {
                    mockElapsedTimePrinter.toReturnResult = "1 min ago"
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                describe("When given no build") {
                    beforeEach {
                        mockElapsedTimePrinter.toReturnResult = "X s ago"
                        subject.setBuild(nil)
                    }

                    it("displays '--' as the name of the build") {
                        expect(subject.latestJobNameLabel?.text).toEventually(equal("--"))
                    }

                    it("displays '--' for the time elapsed since the build started") {
                        expect(subject.latestJobLastEventTimeLabel?.text).toEventually(equal("--"))
                    }

                    it("sets the time title label to '--'") {
                        expect(subject.timeHeaderLabel?.text).toEventually(equal("--"))
                    }

                    it("creates a 'Pending' badge") {
                        expect(subject.buildStatusBadge?.status).toEventually(equal(BuildStatus.pending))
                    }

                    it("disables the 'Retrigger' button") {
                        expect(subject.retriggerButton?.isEnabled).toEventually(beFalse())
                    }
                }

                describe("Setting up a build") {
                    describe("When the build has an end time") {
                        beforeEach {
                            let build = BuildBuilder().withName("the last build").withStartTime(1000).withEndTime(1030).build()
                            mockElapsedTimePrinter.toReturnResult = "X s ago"
                            subject.setBuild(build)
                        }

                        it("displays the name of the build") {
                            expect(subject.latestJobNameLabel?.text).toEventually(equal("#the last build"))
                        }

                        it("displays the time elapsed since the build finished") {
                            expect(mockElapsedTimePrinter.capturedTime).to(equal(1030))
                            expect(subject.latestJobLastEventTimeLabel?.text).toEventually(equal("X s ago"))
                        }

                        it("sets the time title label to 'Finished'") {
                            expect(subject.timeHeaderLabel?.text).to(equal("Finished"))
                        }
                    }

                    describe("When the build has a start time") {
                        beforeEach {
                            let build = BuildBuilder().withName("the next build").withStartTime(1000).withEndTime(nil).build()
                            subject.setBuild(build)
                        }

                        it("displays the name of the build") {
                            expect(subject.latestJobNameLabel?.text).toEventually(equal("#the next build"))
                        }

                        it("displays the time elapsed since the build started") {
                            expect(mockElapsedTimePrinter.capturedTime).to(equal(1000))
                            expect(subject.latestJobLastEventTimeLabel?.text).toEventually(equal("1 min ago"))
                        }

                        it("sets the time title label to 'Started'") {
                            expect(subject.timeHeaderLabel?.text).to(equal("Started"))
                        }
                    }

                    describe("When the build has no start time") {
                        beforeEach {
                            let build = BuildBuilder().withName("the next build").withStartTime(nil).withEndTime(nil).build()
                            subject.setBuild(build)
                        }

                        it("displays the name of the build") {
                            expect(subject.latestJobNameLabel?.text).toEventually(equal("#the next build"))
                        }

                        it("displays two dashes for the time label") {
                            expect(mockElapsedTimePrinter.capturedTime).to(beNil())
                            expect(subject.latestJobLastEventTimeLabel?.text).toEventually(equal("--"))
                        }

                        it("sets the time title label to a blank string ''") {
                            expect(subject.timeHeaderLabel?.text).to(equal(""))
                        }
                    }

                    describe("Tapping the 'Retrigger' button after setting up with a job") {
                        beforeEach {
                            let build = BuildBuilder()
                                .withName("the next build")
                                .withJobName("job_name")
                                .withStartTime(1000)
                                .withEndTime(nil)
                                .build()
                            subject.setBuild(build)

                            try! subject.retriggerButton?.tap()
                        }

                        it("disables the button") {
                            expect(subject.retriggerButton?.isEnabled).toEventually(beFalse())
                        }

                        it("asks the \(TriggerBuildService.self) to trigger a new build") {
                            let expectedTarget = Target(name: "turtle target", api: "turtle api", teamName: "turtle team name", token: Token(value: "turtle token value"))
                            expect(mockTriggerBuildService.capturedTarget).to(equal(expectedTarget))
                            expect(mockTriggerBuildService.capturedJobName).to(equal("job_name"))
                            expect(mockTriggerBuildService.capturedPipelineName).to(equal("pipeline_name"))
                        }

                        describe("When the \(TriggerBuildService.self) returns with a build that was triggered") {
                            beforeEach {
                                let build = BuildBuilder()
                                    .withId(124)
                                    .build()

                                mockTriggerBuildService.triggeredBuildSubject.onNext(build)
                            }

                            it("presents an alert informing the user of the build that was triggered") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Triggered"))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Build #124 triggered for 'jobName'"))
                            }

                            it("enables the button") {
                                expect(subject.retriggerButton?.isEnabled).toEventually(beTrue())
                            }
                        }

                        describe("When the \(TriggerBuildService.self) returns with an error") {
                            beforeEach {
                                mockTriggerBuildService.triggeredBuildSubject.onError(BasicError(details: "turtle trigger error"))
                            }

                            it("presents an alert informing the user of the error") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Trigger Failed"))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Failed to trigger a new build. Please try again later."))
                            }

                            it("enables the button") {
                                expect(subject.retriggerButton?.isEnabled).toEventually(beTrue())
                            }
                        }
                    }
                }
            }
        }
    }
}
