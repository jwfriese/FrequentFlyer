import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class JobDetailViewControllerSpec: QuickSpec {
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

    override func spec() {
        fdescribe("JobDetailViewController") {
            var subject: JobDetailViewController!
            var mockTriggerBuildService: MockTriggerBuildService!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                subject = storyboard.instantiateViewController(withIdentifier: JobDetailViewController.storyboardIdentifier) as! JobDetailViewController

                let job = Job(
                    name: "turtle job",
                    builds: [
                        Build(
                            id: 1,
                            name: "some build",
                            teamName: "turtle team",
                            jobName: "turtle job",
                            status: "build status",
                            pipelineName: "turtle pipeline"
                        )
                    ]
                )
                subject.job = job
            }

            describe("After the view loads") {
                beforeEach {
                    let _ = Fleet.setInAppWindowRootNavigation(subject)
                }

                it("sets the title") {
                    expect(subject.title).toEventually(equal("turtle job"))
                }

                it("sets up its control panel") {
                    expect(subject.controlPanel?.latestJobNameLabel?.text).toEventually(equal("some build"))
                    expect(subject.controlPanel?.latestJobStatusLabel?.text).toEventually(equal("build status"))
                }

                describe("Tapping the 'Retrigger' button") {
                    beforeEach {
                        try! subject.retriggerButton?.tap()
                    }

                    it("asks the \(TriggerBuildService.self) to trigger a new build") {
                        let expectedTarget = Target(name: "turtle target", api: "turtle api", teamName: "turtle team name", token: Token(value: "turtle token value"))
                        expect(mockTriggerBuildService.capturedTarget).to(equal(expectedTarget))
                        expect(mockTriggerBuildService.capturedJobName).to(equal("turtle job"))
                        expect(mockTriggerBuildService.capturedPipelineName).to(equal("turtle pipeline"))
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
                                jobName: "turtle job",
                                status: "turtle pending",
                                pipelineName: "turtle pipeline"
                            )

                            completion(build, nil)
                        }

                        it("presents an alert informing the user of the build that was triggered") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Build Triggered"))
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Build #124 triggered for turtle job"))
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
