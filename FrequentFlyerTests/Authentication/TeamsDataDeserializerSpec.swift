import XCTest
import Quick
import Nimble
import RxSwift

@testable import FrequentFlyer

class TeamsDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("TeamsDataDeserializer") {
            var subject: TeamsDataDeserializer!
            let publishSubject = PublishSubject<String>()
            var result: StreamResult<String>!
            var teams: [String] {
                get {
                    return result.elements
                }
            }

            beforeEach {
                subject = TeamsDataDeserializer()
            }

            describe("Deserializing teams data that is all valid") {

                beforeEach {
                    let validDataJSONArray = [
                        [
                            "name": "puppy_team"
                        ],
                        [
                            "name": "crab_team"
                        ]
                    ]

                    let validData = try! JSONSerialization.data(withJSONObject: validDataJSONArray, options: .prettyPrinted)
                    result = StreamResult(subject.deserialize(validData))
                }

                it("returns a team name for each JSON team entry") {
                    if teams.count != 2 {
                        fail("Expected to return 2 team names, returned \(teams.count)")
                        return
                    }

                    expect(teams[0]).to(equal("puppy_team"))
                    expect(teams[1]).to(equal("crab_team"))
                }

                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }

            describe("Deserializing team data where some of the data is invalid") {
                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "puppy_team",
                            ],
                            [
                                "somethingelse" : "value",
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a team name for each valid JSON team entry") {
                        expect(teams).to(equal(["puppy_team"]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "name" : "crab_team"
                            ],
                            [
                                "name" : 1
                            ]
                        ]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidDataJSONArray, options: .prettyPrinted)
                        result = StreamResult(subject.deserialize(partiallyValidData))
                    }

                    it("emits a team name for each valid JSON team entry") {
                        expect(teams).to(equal(["crab_team"]))
                    }

                    it("emits completed") {
                        expect(result.completed).to(beTrue())
                    }
                }
            }

            describe("Given data cannot be interpreted as JSON") {
                beforeEach {
                    let teamsDataString = "some string"

                    let invalidTeamsData = teamsDataString.data(using: String.Encoding.utf8)
                    result = StreamResult(subject.deserialize(invalidTeamsData!))
                }

                it("emits no team names") {
                    expect(teams).to(haveCount(0))
                }

                it("emits an error") {
                    expect(result.error as? DeserializationError).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat)))
                }
            }
        }
    }
}
