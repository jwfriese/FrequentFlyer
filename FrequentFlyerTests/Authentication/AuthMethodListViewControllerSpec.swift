import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class AuthMethodListViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AuthMethodListViewController") {
            var subject: AuthMethodListViewController!

            var mockBasicUserAuthViewController: BasicUserAuthViewController!
            var mockGithubAuthViewController: GithubAuthViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockBasicUserAuthViewController = try! storyboard.mockIdentifier(BasicUserAuthViewController.storyboardIdentifier, usingMockFor: BasicUserAuthViewController.self)

                mockGithubAuthViewController = try! storyboard.mockIdentifier(GithubAuthViewController.storyboardIdentifier, usingMockFor: GithubAuthViewController.self)

                subject = storyboard.instantiateViewController(withIdentifier: AuthMethodListViewController.storyboardIdentifier) as? AuthMethodListViewController

                subject.authMethods = [
                    AuthMethod(type: .basic, url: "basic-auth.com"),
                    AuthMethod(type: .github, url: "github-auth.com")
                ]
                subject.concourseURLString = "turtle concourse"
            }

            describe("After the view loads") {
                beforeEach {
                    let navigationController = UINavigationController(rootViewController: subject)
                    Fleet.setApplicationWindowRootViewController(navigationController)
                }

                it("sets a blank title") {
                    expect(subject.title).to(equal(""))
                }

                it("sets itself as the data source for its table view") {
                    expect(subject.authMethodListTableView?.dataSource).to(beIdenticalTo(subject))
                }

                it("sets itself as the delegate for its table view") {
                    expect(subject.authMethodListTableView?.delegate).to(beIdenticalTo(subject))
                }

                describe("Displaying auth methods") {
                    it("adds a row to the table for each auth method") {
                        expect(subject.tableView(subject.authMethodListTableView!, numberOfRowsInSection: 0)).to(equal(2))
                    }

                    it("creates a cell in each of the rows for each of the auth methods") {
                        let cellOne = subject.tableView(subject.authMethodListTableView!, cellForRowAt: IndexPath(row: 0, section: 0))
                        expect(cellOne).toNot(beNil())

                        guard let cellOneLabel = cellOne.textLabel else {
                            fail("Failed to pull the UITableViewCell for basic auth method from the table")
                            return
                        }
                        expect(cellOneLabel.text).to(equal("Basic"))

                        let cellTwo = subject.tableView(subject.authMethodListTableView!, cellForRowAt: IndexPath(row: 1, section: 0))
                        expect(cellTwo).toNot(beNil())

                        guard let cellTwoLabel = cellTwo.textLabel else {
                            fail("Failed to pull the UITableViewCell for basic auth method from the table")
                            return
                        }
                        expect(cellTwoLabel.text).to(equal("Github"))
                    }

                    describe("Tapping a basic auth cell") {
                        beforeEach {
                            subject.tableView(subject.authMethodListTableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
                        }

                        it("presents a BasicUserAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockBasicUserAuthViewController))
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? BasicUserAuthViewController)?.concourseURLString).toEventually(equal("turtle concourse"))
                        }

                        it("sets a KeychainWrapper on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? BasicUserAuthViewController)?.keychainWrapper).toEventuallyNot(beNil())
                        }
                    }

                    describe("Tapping a Github auth cell") {
                        beforeEach {
                            subject.tableView(subject.authMethodListTableView!, didSelectRowAt: IndexPath(row: 1, section: 0))
                        }

                        it("presents a GithubAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockGithubAuthViewController))
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect(mockGithubAuthViewController.concourseURLString).toEventually(equal("turtle concourse"))
                        }

                        it("sets the auth method's auth URL on the view controller") {
                            expect(mockGithubAuthViewController.githubAuthURLString).to(equal("github-auth.com"))
                        }
                    }
                }
            }
        }
    }
}
