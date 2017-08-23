import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class PublicPipelinesDataStreamProducerSpec: QuickSpec {
    class MockPublicPipelinesService: PublicPipelinesService {
        var capturedConcourseURL: String?
        var publishSubject = PublishSubject<[Pipeline]>()

        override func getPipelines(forConcourseWithURL concourseURL: String) -> Observable<[Pipeline]> {
            capturedConcourseURL = concourseURL
            return publishSubject
        }
    }

    override func spec() {
        var subject: PublicPipelinesDataStreamProducer!
        var mockPublicPipelinesService: MockPublicPipelinesService!

        describe("\(PublicPipelinesDataStreamProducer.self)") {
            beforeEach {
                subject = PublicPipelinesDataStreamProducer()

                mockPublicPipelinesService = MockPublicPipelinesService()
                subject.publicPipelinesService = mockPublicPipelinesService
            }

            describe("Opening a data stream") {
                var pipelineSection$: Observable<[PipelineGroupSection]>!
                var pipelineSectionStreamResult: StreamResult<PipelineGroupSection>!

                beforeEach {
                    pipelineSection$ = subject.openStream(forConcourseWithURL: "concourseURL")
                    pipelineSectionStreamResult = StreamResult(pipelineSection$)
                }

                it("asks the \(PublicPipelinesService.self) to fetch the Concourse's public pipelines") {
                    expect(mockPublicPipelinesService.capturedConcourseURL).to(equal("concourseURL"))
                }

                describe("When the \(PublicPipelinesService.self) resolves with public pipelines") {
                    var pipelineOne: Pipeline!
                    var pipelineTwo: Pipeline!
                    var pipelineThree: Pipeline!
                    var pipelineFour: Pipeline!
                    var pipelineFive: Pipeline!

                    beforeEach {
                        pipelineOne = Pipeline(name: "pipeline one", isPublic: false, teamName: "turtle")
                        pipelineTwo = Pipeline(name: "pipeline two", isPublic: true, teamName: "cat")
                        pipelineThree = Pipeline(name: "pipeline three", isPublic: true, teamName: "turtle")
                        pipelineFour = Pipeline(name: "pipeline four", isPublic: true, teamName: "dog")
                        pipelineFive = Pipeline(name: "pipeline five", isPublic: true, teamName: "dog")

                        mockPublicPipelinesService.publishSubject.onNext(
                            [pipelineOne, pipelineTwo, pipelineThree, pipelineFour, pipelineFive]
                        )
                    }

                    it("organizes the public pipelines into sections by team name sorted alphabetically and emits them") {
                        expect(pipelineSectionStreamResult.elements.count).to(equal(3))
                        expect(pipelineSectionStreamResult.elements[0].items).to(equal([pipelineTwo]))
                        expect(pipelineSectionStreamResult.elements[1].items).to(equal([pipelineFour, pipelineFive]))
                        expect(pipelineSectionStreamResult.elements[2].items).to(equal([pipelineThree]))
                    }
                }
            }
        }
    }
}
