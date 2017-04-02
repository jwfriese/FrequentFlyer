import XCTest
import Quick
import Nimble
import Fleet

@testable import FrequentFlyer

class JobControlPanelViewControllerSpec: QuickSpec {
    override func spec() {
        class MockTriggerBuildService: TriggerBuildService {
            var capturedTarget: Target?
            var capturedJobName: String?
            var capturedPipelineName: String?
            var capturedCompletion: ((Build?, Error?) -> ())?

            override func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String, completion: ((Build?, Error?) -> ())?) {
                capturedTarget = target
                capturedJobName = jobName
                capturedPipelineName = pipelineName
                capturedCompletion = completion
            }
        }

        class MockElapsedTimePrinter: ElapsedTimePrinter {
            var capturedTime: TimeInterval?
            var toReturnResult = ""

            override func printTime(since timePassedInSeconds: TimeInterval) -> String {
                capturedTime = timePassedInSeconds
                return toReturnResult
            }
        }

        describe("JobControlPanelViewController") {
            var subject: JobControlPanelViewController!
            var mockTriggerBuildService: MockTriggerBuildService!
            var mockElapsedTimePrinter: MockElapsedTimePrinter!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                subject = storyboard.instantiateViewController(withIdentifier: JobControlPanelViewController.storyboardIdentifier) as? JobControlPanelViewController

                mockTriggerBuildService = MockTriggerBuildService()
                subject.triggerBuildService = mockTriggerBuildService

                let target = Target(name: "turtle target",
                                    api: "turtle api",
                                    teamName: "turtle team name",
                                    token: Token(value: "turtle token value")
                )

                subject.target = target

                subject.pipeline = Pipeline(name: "pipeline_name")

                mockElapsedTimePrinter = MockElapsedTimePrinter()
                subject.elapsedTimePrinter = mockElapsedTimePrinter
            }

            describe("After the view loads") {
                beforeEach {
                    mockElapsedTimePrinter.toReturnResult = "1 min ago"
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                describe("Setting up the job") {
                    beforeEach {
                        let latestBuild = BuildBuilder().withName("the last build").withEndTime(1000).build()
                        subject.setJob(Job(name: "job_name", builds: [latestBuild]))
                    }

                    it("displays the name of the latest build") {
                        expect(subject.latestJobNameLabel?.text).toEventually(equal("the last build"))
                    }

                    it("displays the time elapsed since the latest build completed") {
                        expect(mockElapsedTimePrinter.capturedTime).to(equal(1000))
                        expect(subject.latestJobLastEventTimeLabel?.text).toEventually(equal("1 min ago"))
                    }

                    describe("Tapping the 'Retrigger' button after setting up with a job") {
                        beforeEach {
                            try! subject.retriggerButton?.tap()
                        }

                        it("asks the \(TriggerBuildService.self) to trigger a new build") {
                            let expectedTarget = Target(name: "turtle target", api: "turtle api", teamName: "turtle team name", token: Token(value: "turtle token value"))
                            expect(mockTriggerBuildService.capturedTarget).to(equal(expectedTarget))
                            expect(mockTriggerBuildService.capturedJobName).to(equal("job_name"))
                            expect(mockTriggerBuildService.capturedPipelineName).to(equal("pipeline_name"))
                        }

                        describe("When the \(TriggerBuildService.self) returns with a build that was triggered") {
                            beforeEach {
                                guard let completion = mockTriggerBuildService.capturedCompletion else {
                                    fail("Failed to call the \(TriggerBuildService.self) with a completion handler")
                                    return
                                }

                                let build = BuildBuilder()
                                    .withId(124)
                                    .build()

                                completion(build, nil)
                            }

                            it("presents an alert informing the user of the build that was triggered") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Triggered"))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Build #124 triggered for 'jobName'"))
                            }
                        }

                        describe("When the \(TriggerBuildService.self) returns with an error") {
                            beforeEach {
                                guard let completion = mockTriggerBuildService.capturedCompletion else {
                                    fail("Failed to call the \(TriggerBuildService.self) with a completion handler")
                                    return
                                }

                                completion(nil, BasicError(details: "turtle trigger error"))
                            }

                            it("presents an alert informing the user of the error") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Trigger Failed"))
                                expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("turtle trigger error"))
                            }
                        }
                    }
                }
            }
        }
    }
}
