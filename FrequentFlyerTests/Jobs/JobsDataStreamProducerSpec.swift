import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class JobsDataStreamProducerSpec: QuickSpec {
    class MockJobsService: JobsService {
        var capturedTarget: Target?
        var capturedPipeline: Pipeline?
        var jobsSubject = PublishSubject<[Job]>()

        override func getJobs(forTarget target: Target, pipeline: Pipeline) -> Observable<[Job]> {
            capturedTarget = target
            capturedPipeline = pipeline
            return jobsSubject
        }
    }

    override func spec() {
        var subject: JobsDataStreamProducer!
        var mockJobsService: MockJobsService!

        describe("\(JobsDataStreamProducer.self)") {
            beforeEach {
                subject = JobsDataStreamProducer()

                mockJobsService = MockJobsService()
                subject.jobsService = mockJobsService
            }

            describe("Opening a data stream") {
                var jobSection$: Observable<[JobGroupSection]>!
                var jobSectionStreamResult: StreamResult<JobGroupSection>!

                beforeEach {
                    let target = Target(
                        name: "turtle target",
                        api: "turtle api",
                        teamName: "turtle team",
                        token: Token(value: "turtle token value")
                    )

                    let pipeline = Pipeline(name: "turtle pipeline")

                    jobSection$ = subject.openStream(forTarget: target, pipeline: pipeline)
                    jobSectionStreamResult = StreamResult(jobSection$)
                }

                it("calls out to the \(JobsService.self)") {
                    let expectedTarget = Target(
                        name: "turtle target",
                        api: "turtle api",
                        teamName: "turtle team",
                        token: Token(value: "turtle token value")
                    )

                    let expectedPipeline = Pipeline(name: "turtle pipeline")

                    expect(mockJobsService.capturedTarget).toEventually(equal(expectedTarget))
                    expect(mockJobsService.capturedPipeline).toEventually(equal(expectedPipeline))
                }

                describe("When the \(JobsService.self) resolves with jobs") {
                    var turtleJob: Job!
                    var crabJob: Job!
                    var anotherCrabJob: Job!
                    var puppyJob: Job!

                    beforeEach {
                        let finishedTurtleBuild = BuildBuilder().withStatus(.failed).withEndTime(1000).build()
                        turtleJob = Job(name: "turtle job", nextBuild: nil, finishedBuild: finishedTurtleBuild, groups: ["turtle-group"])

                        let nextCrabBuild = BuildBuilder().withStatus(.pending).withStartTime(500).build()
                        crabJob = Job(name: "crab job", nextBuild: nextCrabBuild, finishedBuild: nil, groups: ["crab-group"])

                        let anotherCrabBuild = BuildBuilder().withStatus(.aborted).withStartTime(501).build()
                        anotherCrabJob = Job(name: "another crab job", nextBuild: anotherCrabBuild, finishedBuild: nil, groups: ["crab-group"])

                        puppyJob = Job(name: "puppy job", nextBuild: nil, finishedBuild: nil, groups: [])

                        mockJobsService.jobsSubject.onNext([turtleJob, crabJob, anotherCrabJob, puppyJob])
                        mockJobsService.jobsSubject.onCompleted()
                    }

                    it("organizes the jobs into sections by group name and emits them") {
                        expect(jobSectionStreamResult.elements[0].items).to(equal([turtleJob]))
                        expect(jobSectionStreamResult.elements[1].items).to(equal([crabJob, anotherCrabJob]))
                        expect(jobSectionStreamResult.elements[2].items).to(equal([puppyJob]))
                    }
                }
            }
        }
    }
}
