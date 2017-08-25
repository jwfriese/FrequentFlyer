import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class JobsServiceSpec: QuickSpec {
    override func spec() {
        class MockHTTPClient: HTTPClient {
            var capturedRequest: URLRequest?
            var callCount = 0

            var responseSubject = PublishSubject<HTTPResponse>()

            override func perform(request: URLRequest) -> Observable<HTTPResponse> {
                capturedRequest = request
                callCount += 1
                return responseSubject
            }
        }

        class MockJobsDataDeserializer: JobsDataDeserializer {
            var capturedData: Data?
            var toReturnJobs: [Job]?
            var toReturnDeserializationError: DeserializationError?

            override func deserialize(_ data: Data) -> Observable<[Job]> {
                capturedData = data
                if let error = toReturnDeserializationError {
                    return Observable.error(error)
                } else {
                    return Observable.from(optional: toReturnJobs)
                }
            }
        }

        describe("JobsService") {
            var subject: JobsService!
            var mockHTTPClient: MockHTTPClient!
            var mockJobsDataDeserializer: MockJobsDataDeserializer!

            beforeEach {
                subject = JobsService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockJobsDataDeserializer = MockJobsDataDeserializer()
                subject.jobsDataDeserializer = mockJobsDataDeserializer
            }

            describe("Getting jobs for a pipeline") {
                var job$: Observable<[Job]>!
                var jobStreamResult: StreamResult<[Job]>!

                beforeEach {
                    let target = Target(name: "turtle target name",
                                        api: "https://api.com",
                                        teamName: "turtle_team_name",
                                        token: Token(value: "Bearer turtle auth token")
                    )

                    let pipeline = Pipeline(name: "turtle_pipeline", isPublic: false, teamName: "")

                    job$ = subject.getJobs(forTarget: target, pipeline: pipeline)
                    jobStreamResult = StreamResult(job$)
                }

                it("passes the necessary request to the HTTPClient") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with HTTPClient")
                        return
                    }

                    expect(request.url?.absoluteString).to(equal("https://api.com/api/v1/teams/turtle_team_name/pipelines/turtle_pipeline/jobs"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("Bearer turtle auth token"))
                    expect(request.httpMethod).to(equal("GET"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    jobStreamResult.disposeBag = DisposeBag()
                    _ = job$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and valid jobs data") {
                    beforeEach {
                        mockJobsDataDeserializer.toReturnJobs = [
                            Job(name: "turtle job", nextBuild: nil, finishedBuild: nil, groups: [])
                        ]

                        let validJobData = "valid job data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validJobData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "valid job data".data(using: String.Encoding.utf8)
                        expect(mockJobsDataDeserializer.capturedData).to(equal(expectedData!))
                    }

                    it("emits deserialized jobs on the returned stream") {
                        expect(jobStreamResult.elements.count).to(equal(1))
                        expect(jobStreamResult.elements[0]).to(equal([Job(name: "turtle job", nextBuild: nil, finishedBuild: nil, groups: [])]))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    beforeEach {
                        mockJobsDataDeserializer.toReturnDeserializationError = DeserializationError(details: "error details", type: .invalidInputFormat)

                        let invalidData = "invalid data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidData, statusCode: 200))
                    }

                    it("calls the completion handler with the error that came from the deserializer") {
                        expect(jobStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with a 401 response") {
                    beforeEach {
                        let unauthorizedData = "not authorized".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: unauthorizedData, statusCode: 401))
                    }

                    it("emits no jobs") {
                        expect(jobStreamResult.elements).to(haveCount(0))
                    }

                    it("emits an \(AuthorizationError.self)") {
                        expect(jobStreamResult.error as? AuthorizationError).toNot(beNil())
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "error details"))
                    }

                    it("emits no jobs") {
                        expect(jobStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(jobStreamResult.error as? BasicError).to(equal(BasicError(details: "error details")))
                    }
                }
            }

            describe("Getting public jobs for a pipeline") {
                var job$: Observable<[Job]>!
                var jobStreamResult: StreamResult<[Job]>!

                beforeEach {
                    let pipeline = Pipeline(name: "turtle_pipeline", isPublic: false, teamName: "turtle_team_name")

                    job$ = subject.getPublicJobs(forPipeline: pipeline, concourseURL: "https://api.com")
                    jobStreamResult = StreamResult(job$)
                }

                it("passes the necessary request to the HTTPClient") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to make request with HTTPClient")
                        return
                    }

                    expect(request.url?.absoluteString).to(equal("https://api.com/api/v1/teams/turtle_team_name/pipelines/turtle_pipeline/jobs"))
                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.httpMethod).to(equal("GET"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    jobStreamResult.disposeBag = DisposeBag()
                    _ = job$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and valid jobs data") {
                    beforeEach {
                        mockJobsDataDeserializer.toReturnJobs = [
                            Job(name: "turtle job", nextBuild: nil, finishedBuild: nil, groups: [])
                        ]

                        let validJobData = "valid job data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validJobData, statusCode: 200))
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "valid job data".data(using: String.Encoding.utf8)
                        expect(mockJobsDataDeserializer.capturedData).to(equal(expectedData!))
                    }

                    it("emits deserialized jobs on the returned stream") {
                        expect(jobStreamResult.elements.count).to(equal(1))
                        expect(jobStreamResult.elements[0]).to(equal([Job(name: "turtle job", nextBuild: nil, finishedBuild: nil, groups: [])]))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    beforeEach {
                        mockJobsDataDeserializer.toReturnDeserializationError = DeserializationError(details: "error details", type: .invalidInputFormat)

                        let invalidData = "invalid data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidData, statusCode: 200))
                    }

                    it("calls the completion handler with the error that came from the deserializer") {
                        expect(jobStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "error details"))
                    }

                    it("emits no jobs") {
                        expect(jobStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(jobStreamResult.error as? BasicError).to(equal(BasicError(details: "error details")))
                    }
                }
            }
        }
    }
}
