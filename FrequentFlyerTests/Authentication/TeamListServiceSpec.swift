import XCTest
import Quick
import Nimble
import RxSwift
import OHHTTPStubs

@testable import FrequentFlyer

class TeamListServiceSpec: QuickSpec {
    class MockTeamsDataDeserializer: TeamsDataDeserializer {
        var capturedData: Data?
        var toReturnTeams: [String]?
        var toReturnDeserializationError: DeserializationError?

        override func deserialize(_ data: Data) -> Observable<[String]> {
            capturedData = data
            if let error = toReturnDeserializationError {
                return Observable.error(error)
            } else {
                return Observable.from(optional: toReturnTeams)
            }
        }
    }

    override func spec() {
        describe("TeamListService") {
            var subject: TeamListService!
            var mockTeamsDataDeserializer: MockTeamsDataDeserializer!

            beforeEach {
                subject = TeamListService()

                mockTeamsDataDeserializer = MockTeamsDataDeserializer()
                subject.teamsDataDeserializer = mockTeamsDataDeserializer
            }

            afterEach {
                OHHTTPStubs.removeAllStubs()
            }

            describe("Fetching teams for a Concourse instance") {
                var team$: Observable<[String]>!
                var teamStreamResult: StreamResult<String>!

                describe("When the request resolves with a success response and teams data") {
                    var validTeamsResponseData: Data!
                    var deserializedTeams: [String]!

                    beforeEach {
                        deserializedTeams = ["crab_team"]
                        mockTeamsDataDeserializer.toReturnTeams = deserializedTeams

                        validTeamsResponseData = "valid teams data".data(using: String.Encoding.utf8)
                        stub(condition: isScheme("http") &&
                            isHost("localhost") &&
                            isPath("/api/v1/teams") &&
                            hasHeaderNamed("Content-Type", value: "application/json")) { _ in
                            return OHHTTPStubsResponse(data: validTeamsResponseData!, statusCode:200, headers:nil)
                        }

                        team$ = subject.getTeams(forConcourseWithURL: "http://localhost:8282")
                        teamStreamResult = StreamResult(team$)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTeamsDataDeserializer.capturedData).toEventually(equal(validTeamsResponseData))
                    }

                    it("emits the teams on the returned stream") {
                        expect(teamStreamResult.elements).toEventually(equal(deserializedTeams))
                    }
                }

                describe("When the request resolves with a success response and deserialization fails") {
                    var invalidTeamsData: Data!

                    beforeEach {
                        mockTeamsDataDeserializer.toReturnDeserializationError = DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)

                        invalidTeamsData = "valid teams data".data(using: String.Encoding.utf8)
                        stub(condition: isScheme("http") &&
                            isHost("localhost") &&
                            isPath("/api/v1/teams") &&
                            hasHeaderNamed("Content-Type", value: "application/json")) { _ in
                            return OHHTTPStubsResponse(data: invalidTeamsData!, statusCode:200, headers:nil)
                        }

                        team$ = subject.getTeams(forConcourseWithURL: "http://localhost:8282")
                        teamStreamResult = StreamResult(team$)
                    }

                    it("passes the data to the deserializer") {
                        expect(mockTeamsDataDeserializer.capturedData).toEventually(equal(invalidTeamsData))
                    }

                    it("emits the error the deserializer returns") {
                        expect(teamStreamResult.error as? DeserializationError).toEventually(equal(DeserializationError(details: "some deserialization error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the request 500s") {
                    beforeEach {
                        stub(condition: isScheme("http") &&
                            isHost("localhost") &&
                            isPath("/api/v1/teams") &&
                            hasHeaderNamed("Content-Type", value: "application/json")) { _ in
                            return OHHTTPStubsResponse(data: "some error response".data(using: String.Encoding.utf8)!, statusCode: 500, headers:nil)
                        }

                        team$ = subject.getTeams(forConcourseWithURL: "http://localhost:8282")
                        teamStreamResult = StreamResult(team$)
                    }

                    it("emits no methods") {
                        expect(teamStreamResult.elements).toEventually(haveCount(0))
                    }

                    it("emits the error that the client returned") {
                        expect(teamStreamResult.error as? BasicError).toEventually(equal(BasicError(details: "some error response")))
                    }
                }
            }
        }
    }
}
