import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class BuildDetailViewControllerSpec: QuickSpec {
    override func spec() {
        class MockTriggerBuildService: TriggerBuildService {
            var capturedTarget: Target?
            var capturedJobName: String?
            var capturedPipelineName: String?
            var capturedCompletion: ((Build?, FFError?) -> ())?

            override func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String, completion: ((Build?, FFError?) -> ())?) {
                capturedTarget = target
                capturedJobName = jobName
                capturedPipelineName = pipelineName
                capturedCompletion = completion
            }
        }

        describe("BuildDetailViewController") {
            var subject: BuildDetailViewController!
            var mockTriggerBuildService: MockTriggerBuildService!

            var mockLogsViewController: LogsViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockLogsViewController = try! storyboard.mockIdentifier(LogsViewController.storyboardIdentifier, usingMockFor: LogsViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: BuildDetailViewController.storyboardIdentifier) as! BuildDetailViewController

                let target = Target(name: "turtle target",
                    api: "turtle api",
                    teamName: "turtle team name",
                    token: Token(value: "turtle token value")
                )

                subject.target = target

                let build = Build(id: 123,
                    jobName: "turtle job",
                    status: "turtle status",
                    pipelineName: "turtle pipeline"
                )

                subject.build = build

                mockTriggerBuildService = MockTriggerBuildService()
                subject.triggerBuildService = mockTriggerBuildService
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

                describe("Tapping the 'Retrigger' button") {
                    beforeEach {
                        subject.retriggerButton?.tap()
                    }

                    it("asks the TriggerBuildService to trigger a new build") {
                        let expectedTarget = Target(name: "turtle target", api: "turtle api", teamName: "turtle team name", token: Token(value: "turtle token value"))
                        expect(mockTriggerBuildService.capturedTarget).to(equal(expectedTarget))
                        expect(mockTriggerBuildService.capturedJobName).to(equal("turtle job"))
                        expect(mockTriggerBuildService.capturedPipelineName).to(equal("turtle pipeline"))
                    }

                    describe("When the TriggerBuildService returns with a build that was triggered") {
                        beforeEach {
                            guard let completion = mockTriggerBuildService.capturedCompletion else {
                                fail("Failed to call the TriggerBuildService with a completion handler")
                                return
                            }

                            let build = Build(id: 124,
                                jobName: "turtle job",
                                status: "turtle pending",
                                pipelineName: "turtle pipeline")

                            completion(build, nil)
                        }

                        it("presents an alert informing the user of the build that was triggered") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Triggered"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Build #124 triggered for turtle job"))
                        }
                    }

                    describe("When the TriggerBuildService returns with an error") {
                        beforeEach {
                            guard let completion = mockTriggerBuildService.capturedCompletion else {
                                fail("Failed to call the TriggerBuildService with a completion handler")
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

                describe("Tapping the 'View Logs' button") {
                    beforeEach {
                        subject.viewLogsButton?.tap()
                    }

                    it("presents a LogsViewController") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockLogsViewController))

                        expect((Fleet.getApplicationScreen()?.topmostViewController as? LogsViewController)?.sseService).toEventuallyNot(beNil())
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? LogsViewController)?.sseService?.eventSourceCreator).toEventuallyNot(beNil())

                        expect((Fleet.getApplicationScreen()?.topmostViewController as? LogsViewController)?.logsStylingParser).toEventuallyNot(beNil())

                        let expectedTarget = Target(name: "turtle target",
                                                    api: "turtle api",
                                                    teamName: "turtle team name",
                                                    token: Token(value: "turtle token value")
                        )

                        let expectedBuild = Build(id: 123,
                                                  jobName: "turtle job",
                                                  status: "turtle status",
                                                  pipelineName: "turtle pipeline"
                        )

                        expect((Fleet.getApplicationScreen()?.topmostViewController as? LogsViewController)?.build).toEventually(equal(expectedBuild))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? LogsViewController)?.target).toEventually(equal(expectedTarget))
                    }
                }
            }
        }
    }
}
