import XCTest
import Quick
import Nimble
import Fleet
@testable import FrequentFlyer

class AuthMethodListViewControllerSpec: QuickSpec {
    class MockBasicUserAuthViewController: BasicUserAuthViewController {
        override func viewDidLoad() { }
    }

    override func spec() {
        describe("AuthMethodListViewController") {
            var subject: AuthMethodListViewController!

            var mockBasicUserAuthViewController: MockBasicUserAuthViewController!

            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                mockBasicUserAuthViewController = MockBasicUserAuthViewController()
                try! storyboard.bindViewController(mockBasicUserAuthViewController, toIdentifier: BasicUserAuthViewController.storyboardIdentifier)

                subject = storyboard.instantiateViewControllerWithIdentifier(AuthMethodListViewController.storyboardIdentifier) as? AuthMethodListViewController

                subject.authMethods = [AuthMethod(type: .Basic), AuthMethod(type: .Github)]
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
                        let cellOne = subject.tableView(subject.authMethodListTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        expect(cellOne).toNot(beNil())

                        guard let cellOneLabel = cellOne.textLabel else {
                            fail("Failed to pull the UITableViewCell for basic auth method from the table")
                            return
                        }
                        expect(cellOneLabel.text).to(equal("Basic"))

                        let cellTwo = subject.tableView(subject.authMethodListTableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                        expect(cellTwo).toNot(beNil())

                        guard let cellTwoLabel = cellTwo.textLabel else {
                            fail("Failed to pull the UITableViewCell for basic auth method from the table")
                            return
                        }
                        expect(cellTwoLabel.text).to(equal("Github"))
                    }

                    describe("Tapping a basic auth cell") {
                        beforeEach {
                            subject.tableView(subject.authMethodListTableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        }

                        it("presents a BasicUserAuthViewController") {
                            expect(Fleet.getApplicationScreen()?.topmostViewController).toEventually(beIdenticalTo(mockBasicUserAuthViewController))
                        }

                        it("sets a BasicAuthTokenService on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService?.httpClient).toEventuallyNot(beNil())
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.basicAuthTokenService?.tokenDataDeserializer).toEventuallyNot(beNil())
                        }

                        it("sets the entered Concourse URL on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.concourseURLString).toEventually(equal("turtle concourse"))
                        }

                        it("sets a KeychainWrapper on the view controller") {
                            expect((Fleet.getApplicationScreen()?.topmostViewController as? MockBasicUserAuthViewController)?.keychainWrapper).toEventuallyNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
