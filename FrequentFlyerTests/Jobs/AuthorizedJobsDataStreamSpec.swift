import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class AuthorizedJobsDataStreamSpec: QuickSpec {
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
        describe("AuthorizedJobsDataStream") {
            var subject: AuthorizedJobsDataStream!

            var mockJobsService: MockJobsService!

            beforeEach {
                let target = Target(
                    name: "turtle target name",
                    api: "https://turtle_api.com",
                    teamName: "turtle team",
                    token: Token(value: "turtle token")
                )

                subject = AuthorizedJobsDataStream(target: target)

                mockJobsService = MockJobsService()
                subject.jobsService = mockJobsService
            }

            describe("Opening a data stream") {
                var jobSection$: Observable<[JobGroupSection]>!
                var jobSectionStreamResult: StreamResult<JobGroupSection>!

                beforeEach {
                    let pipeline = Pipeline(name: "turtle pipeline", isPublic: true, teamName: "turtle team")
                    jobSection$ = subject.open(forPipeline: pipeline)
                    jobSectionStreamResult = StreamResult(jobSection$)
                }

                it("calls out to the \(JobsService.self)") {
                    let expectedTarget = Target(
                        name: "turtle target name",
                        api: "https://turtle_api.com",
                        teamName: "turtle team",
                        token: Token(value: "turtle token")
                    )
                    expect(mockJobsService.capturedTarget).toEventually(equal(expectedTarget))

                    let expectedPipeline = Pipeline(name: "turtle pipeline", isPublic: true, teamName: "turtle team")
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
