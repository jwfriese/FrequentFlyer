import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class TeamListServiceSpec: QuickSpec {
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

    class MockTeamsDataDeserializer: TeamsDataDeserializer {
        var capturedData: Data?
        var toReturnTeams: [String]?
        var toReturnDeserializationError: DeserializationError?

        override func deserialize(_ data: Data) -> Observable<[String]> {
            capturedData = data
            let subject = ReplaySubject<[String]>.createUnbounded()
            if let error = toReturnDeserializationError {
                subject.onError(error)
            } else {
                if let teams = toReturnTeams {
                    subject.onNext(teams)
                }
                subject.onCompleted()
            }
            return subject
        }
    }

    override func spec() {
        describe("TeamListService") {
            var subject: TeamListService!
            var mockHTTPClient: MockHTTPClient!
            var mockTeamsDataDeserializer: MockTeamsDataDeserializer!

            beforeEach {
                subject = TeamListService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockTeamsDataDeserializer = MockTeamsDataDeserializer()
                subject.teamsDataDeserializer = mockTeamsDataDeserializer
            }

            describe("Fetching teams for a Concourse instance") {
                var team$: Observable<[String]>!
                var teamStreamResult: StreamResult<String>!

                beforeEach {
                    team$ = subject.getTeams(forConcourseWithURL: "https://concourse.com")
                    teamStreamResult = StreamResult(team$)
                }

                it("asks the \(HTTPClient.self) to get the team's auth methods") {
                    guard let request = mockHTTPClient.capturedRequest else {
                        fail("Failed to use the \(HTTPClient.self) to make a request")
                        return
                    }

                    expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(request.httpMethod).to(equal("GET"))
                    expect(request.url?.absoluteString).to(equal("https://concourse.com/api/v1/teams"))
                }

                it("does not ask the HTTP client a second time when a second subscribe occurs") {
                    teamStreamResult.disposeBag = DisposeBag()
                    _ = team$.subscribe()

                    expect(mockHTTPClient.callCount).to(equal(1))
                }

                describe("When the request resolves with a success response and teams data") {
                    var validTeamsResponseData: Data!
                    var deserializedTeams: [String]!

                    beforeEach {
                        deserializedTeams = ["crab_team"]
                        mockTeamsDataDeserializer.toReturnTeams = deserializedTeams

                        validTeamsResponseData = "valid teams data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: validTeamsResponseData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTeamsDataDeserializer.capturedData).to(equal(validTeamsResponseData))
                    }

                    it("emits the teams on the returned stream") {
                        expect(teamStreamResult.elements).to(equal(deserializedTeams))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    var invalidTeamsData: Data!

                    beforeEach {
                        mockTeamsDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidTeamsData = "valid teams data".data(using: String.Encoding.utf8)
                        mockHTTPClient.responseSubject.onNext(HTTPResponseImpl(body: invalidTeamsData, statusCode: 200))
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTeamsDataDeserializer.capturedData).to(equal(invalidTeamsData))
                    }

                    it("emits the error the deserializer returns") {
                        expect(teamStreamResult.error as? DeserializationError).to(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request resolves with an error response") {
                    beforeEach {
                        mockHTTPClient.responseSubject.onError(BasicError(details: "some error string"))
                    }

                    it("emits no methods") {
                        expect(teamStreamResult.elements).to(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(teamStreamResult.error as? BasicError).to(equal(BasicError(details: "some error string")))
                    }
                }
            }
        }
    }
}
