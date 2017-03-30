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

        describe("JobControlPanelViewController") {
            var subject: JobControlPanelViewController!
            var mockTriggerBuildService: MockTriggerBuildService!

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
                subject.job = Job(name: "job_name", builds: [])
            }

            describe("After the view loads") {
                beforeEach {
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                describe("Tapping the 'Retrigger' button") {
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

                            let build = Build(
                                id: 124,
                                name: "name",
                                teamName: "team name",
                                jobName: "job_name",
                                status: "turtle pending",
                                pipelineName: "pipeline_name"
                            )

                            completion(build, nil)
                        }

                        it("presents an alert informing the user of the build that was triggered") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Triggered"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Build #124 triggered for 'job_name'"))
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
