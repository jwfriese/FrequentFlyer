import XCTest
import Quick
import Nimble
import Fleet
import RxSwift

@testable import FrequentFlyer

class TeamsViewControllerSpec: QuickSpec {
    class MockTeamListService: TeamListService {
        var capturedConcourseURL: String?
        var teamListSubject = PublishSubject<[String]>()

        override func getTeams(forConcourseWithURL concourseURL: String) -> Observable<[String]> {
            capturedConcourseURL = concourseURL
            return teamListSubject
        }
    }

    class MockAuthMethodsService: AuthMethodsService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var authMethodsSubject = PublishSubject<[AuthMethod]>()

        override func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<[AuthMethod]> {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            return authMethodsSubject
        }
    }

    class MockUnauthenticatedTokenService: UnauthenticatedTokenService {
        var capturedTeamName: String?
        var capturedConcourseURL: String?
        var tokenSubject = PublishSubject<Token>()


        override func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String) -> Observable<Token> {
            capturedTeamName = teamName
            capturedConcourseURL = concourseURL
            return tokenSubject
        }
    }

    override func spec() {
        describe("TeamsViewController"){
            var subject: TeamsViewController!
            var mockTeamListService: MockTeamListService!
            var mockAuthMethodsService: MockAuthMethodsService!
            var mockUnauthenticatedTokenService: MockUnauthenticatedTokenService!

            var mockLoginViewController: LoginViewController!
            var mockGitHubAuthViewController: GitHubAuthViewController!
            var mockPipelinesViewController: PipelinesViewController!

            func returnAuthMethods(_ methods: [AuthMethod]) {
                let methodSubject = mockAuthMethodsService.authMethodsSubject
                methodSubject.onNext(methods)
                methodSubject.onCompleted()
            }

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockLoginViewController = try! storyboard.mockIdentifier(LoginViewController.storyboardIdentifier, usingMockFor: LoginViewController.self)
                mockGitHubAuthViewController = try! storyboard.mockIdentifier(GitHubAuthViewController.storyboardIdentifier, usingMockFor: GitHubAuthViewController.self)
                mockPipelinesViewController = try! storyboard.mockIdentifier(PipelinesViewController.storyboardIdentifier, usingMockFor: PipelinesViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: TeamsViewController.storyboardIdentifier) as! TeamsViewController

                mockTeamListService = MockTeamListService()
                subject.teamListService = mockTeamListService

                mockAuthMethodsService = MockAuthMethodsService()
                subject.authMethodsService = mockAuthMethodsService

                mockUnauthenticatedTokenService = MockUnauthenticatedTokenService()
                subject.unauthenticatedTokenService = mockUnauthenticatedTokenService

                subject.concourseURLString = "https://concourse.com"
            }

            describe("After the view has loaded") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setAsAppWindowRoot(navigationController)
                }

                it("sets the title") {
                    expect(subject.title).to(equal("Teams"))
                }

                it("makes a call to the team list service") {
                    expect(mockTeamListService.capturedConcourseURL).toEventually(equal("https://concourse.com"))
                }

                describe("When the team list service call resolves with some team names") {
                    beforeEach {
                        mockTeamListService.teamListSubject.onNext(["turtle_team", "crab_team", "puppy_team"])
                        mockTeamListService.teamListSubject.onCompleted()
                    }

                    it("adds a row to the table for each of the teams") {
                        expect(subject.teamsTableView!.numberOfRows(inSection: 0)).toEventually(equal(3))
                    }

                    it("creates a cell in each of the rows for each of the pipelines returned") {
                        let cellOne = subject.teamsTableView!.fetchCell(at: IndexPath(row: 0, section: 0), asType: TeamTableViewCell.self)
                        expect(cellOne.teamLabel?.text).to(equal("turtle_team"))

                        let cellTwo = subject.teamsTableView!.fetchCell(at: IndexPath(row: 1, section: 0), asType: TeamTableViewCell.self)
                        expect(cellTwo.teamLabel?.text).to(equal("crab_team"))

                        let cellThree = subject.teamsTableView!.fetchCell(at: IndexPath(row: 2, section: 0), asType: TeamTableViewCell.self)
                        expect(cellThree.teamLabel?.text).to(equal("puppy_team"))
                    }

                    describe("Tapping one of the cells") {
                        beforeEach {
                            subject.teamsTableView!.selectRow(at: IndexPath(row: 0, section: 0))
                        }

                        it("immediately deselects the cell") {
                            let selectedCell = subject.teamsTableView?.cellForRow(at: IndexPath(row: 0, section: 0))
                            expect(selectedCell).toEventuallyNot(beNil())
                            expect(selectedCell?.isHighlighted).toEventually(beFalse())
                        }

                        it("makes a call to the auth methods service using the tapped cell's team and Concourse URL") {
                            expect(mockAuthMethodsService.capturedTeamName).to(equal("turtle_team"))
                            expect(mockAuthMethodsService.capturedConcourseURL).to(equal("https://concourse.com"))
                        }

                        describe("When the auth methods service call resolves with many auth methods") {
                            beforeEach {
                                let basicAuthMethod = AuthMethod(type: .basic, displayName: "", url: "basic-auth.com")
                                let gitHubAuthMethod = AuthMethod(type: .gitHub, displayName: "", url: "gitHub-auth.com")
                                returnAuthMethods([basicAuthMethod, gitHubAuthMethod])
                            }

                            it("presents a \(LoginViewController.self)") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockLoginViewController))
                            }

                            it("sets the fetched auth methods on the view controller") {
                                expect(mockLoginViewController.authMethods).toEventually(equal([
                                    AuthMethod(type: .basic, displayName: "", url: "basic-auth.com"),
                                    AuthMethod(type: .gitHub, displayName: "", url: "gitHub-auth.com")
                                    ]))
                            }

                            it("sets the Concourse URL on the view controller") {
                                expect(mockLoginViewController.concourseURLString).toEventually(equal("https://concourse.com"))
                            }

                            it("sets the selected team on the view controller") {
                                expect(mockLoginViewController.teamName).toEventually(equal("turtle_team"))
                            }
                        }

                        describe("When the auth methods service call resolves only with GitHub authentication") {
                            beforeEach {
                                let gitHubAuthMethod = AuthMethod(type: .gitHub, displayName: "", url: "gitHub-auth.com")
                                returnAuthMethods([gitHubAuthMethod])
                            }

                            it("presents a \(GitHubAuthViewController.self)") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockGitHubAuthViewController))
                            }

                            it("sets the entered Concourse URL on the view controller") {
                                expect(mockGitHubAuthViewController.concourseURLString).toEventually(equal("https://concourse.com"))
                            }

                            it("sets the auth method's auth URL on the view controller") {
                                expect(mockGitHubAuthViewController.gitHubAuthURLString).toEventually(equal("gitHub-auth.com"))
                            }

                            it("sets the selected team on the view controller") {
                                expect(mockGitHubAuthViewController.teamName).toEventually(equal("turtle_team"))
                            }
                        }

                        describe("When the auth methods service call resolves with GitHub and UAA authentication") {
                            beforeEach {
                                let gitHubAuthMethod = AuthMethod(type: .gitHub, displayName: "", url: "gitHub-auth.com")
                                let uaaAuthMethod = AuthMethod(type: .uaa, displayName: "", url: "uaa-auth.com")
                                returnAuthMethods([gitHubAuthMethod, uaaAuthMethod])
                            }

                            it("presents a \(GitHubAuthViewController.self)") {
                                expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockGitHubAuthViewController))
                            }

                            it("sets the entered Concourse URL on the view controller") {
                                expect(mockGitHubAuthViewController.concourseURLString).toEventually(equal("https://concourse.com"))
                            }

                            it("sets the auth method's auth URL on the view controller") {
                                expect(mockGitHubAuthViewController.gitHubAuthURLString).toEventually(equal("gitHub-auth.com"))
                            }

                            it("sets the selected team on the view controller") {
                                expect(mockGitHubAuthViewController.teamName).toEventually(equal("turtle_team"))
                            }
                        }

                        describe("When the auth methods service call resolves with only UAA authentication") {
                            beforeEach {
                                let uaaAuthMethod = AuthMethod(type: .uaa, displayName: "", url: "uaa-auth.com")
                                returnAuthMethods([uaaAuthMethod])
                            }

                            it("presents an alert that lets the user know that the app does not yet support UAA") {
                                expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                                let screen = Fleet.getApplicationScreen()
                                expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                                let alert = screen?.topmostViewController as? UIAlertController
                                expect(alert?.title).toEventually(equal("Unsupported Auth Method"))
                                expect(alert?.message).toEventually(equal("The app does not support UAA yet."))
                            }
                        }

                        describe("When the auth methods service call resolves with no auth methods and no error") {
                            beforeEach {
                                returnAuthMethods([])
                            }

                            it("makes a call to the token auth service using the input team, Concourse URL, and no other credentials") {
                                expect(mockUnauthenticatedTokenService.capturedTeamName).to(equal("turtle_team"))
                                expect(mockUnauthenticatedTokenService.capturedConcourseURL).to(equal("https://concourse.com"))
                            }

                            describe("When the unauthenticated token auth service call resolves with a valid token") {
                                beforeEach {
                                    let token = Token(value: "turtle auth token")
                                    mockUnauthenticatedTokenService.tokenSubject.onNext(token)
                                }

                                it("replaces itself with the \(PipelinesViewController.self)") {
                                    expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockPipelinesViewController))
                                }

                                it("creates a new target from the entered information and view controller") {
                                    let expectedTarget = Target(name: "target", api: "https://concourse.com",
                                                                teamName: "turtle_team", token: Token(value: "turtle auth token")
                                    )
                                    expect(mockPipelinesViewController.target).toEventually(equal(expectedTarget))
                                }
                            }

                            describe("When the unauthenticated token auth service call resolves with some error") {
                                beforeEach {
                                    let error = BasicError(details: "error details")
                                    mockUnauthenticatedTokenService.tokenSubject.onError(error)
                                }

                                it("presents an alert that contains the error message from the token auth service") {
                                    expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                                    let screen = Fleet.getApplicationScreen()
                                    expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                                    let alert = screen?.topmostViewController as? UIAlertController
                                    expect(alert?.title).toEventually(equal("Error"))
                                    expect(alert?.message).toEventually(equal("Failed to fetch authentication methods and failed to fetch a token without credentials."))
                                }
                            }
                        }

                        describe("When the auth methods service call resolves with an error") {
                            beforeEach {
                                let error = BasicError(details: "error details")
                                mockAuthMethodsService.authMethodsSubject.onError(error)
                            }

                            it("presents an alert that contains the error message from the token auth service") {
                                expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                                let screen = Fleet.getApplicationScreen()
                                expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                                let alert = screen?.topmostViewController as? UIAlertController
                                expect(alert?.title).toEventually(equal("Error"))
                                expect(alert?.message).toEventually(equal("Encountered error when trying to fetch Concourse auth methods. Please check your Concourse configuration and try again later."))
                            }
                        }
                    }
                }

                describe("When the team list service call resolves with no teams") {
                    beforeEach {
                        mockTeamListService.teamListSubject.onNext([])
                        mockTeamListService.teamListSubject.onCompleted()
                    }

                    it("presents an alert informing the user that there appear to be no teams") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("No Teams"))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not find any teams for this Concourse instance."))
                    }
                }

                describe("When the team list service call resolves with an error") {
                    beforeEach {
                        mockTeamListService.teamListSubject.onError(BasicError(details: ""))
                        mockTeamListService.teamListSubject.onCompleted()
                    }

                    it("presents an alert informing the user of the build that was triggered") {
                        expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.title).toEventually(equal("Error"))
                        expect((Fleet.getApplicationScreen()?.topmostViewController as? UIAlertController)?.message).toEventually(equal("Could not connect to a Concourse at the given URL."))
                    }
                }
            }
        }
    }
}
