import UIKit

class AuthMethodListViewController: UIViewController {
    @IBOutlet weak var authMethodListTableView: UITableView?

    var authMethods: [AuthMethod]? {
        didSet {
            authMethodListTableView?.reloadData()
        }
    }
    var concourseURLString: String?

    class var storyboardIdentifier: String { get { return "AuthMethodList" } }
    class var showBasicUserAuthSegueId: String { get { return "ShowBasicUserAuth" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        authMethodListTableView?.delegate = self
        authMethodListTableView?.dataSource = self
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AuthMethodListViewController.showBasicUserAuthSegueId {
            guard let basicUserAuthViewController = segue.destinationViewController as? BasicUserAuthViewController else {
                return
            }

            guard let concourseURLString = concourseURLString else { return }
            basicUserAuthViewController.concourseURLString = concourseURLString
            basicUserAuthViewController.keychainWrapper = KeychainWrapper()

            let basicAuthTokenService = BasicAuthTokenService()
            basicAuthTokenService.httpClient = HTTPClient()
            basicAuthTokenService.tokenDataDeserializer = TokenDataDeserializer()
            basicUserAuthViewController.basicAuthTokenService = basicAuthTokenService
        }
    }
}

extension AuthMethodListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let authMethods = authMethods else { return 0 }
        return authMethods.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let authMethods = authMethods {
            switch authMethods[indexPath.row].type {
            case .Basic:
                cell.textLabel?.text = "Basic"
            case .Github:
                cell.textLabel?.text = "Github"
            }
        }

        return cell
    }
}

extension AuthMethodListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let authMethods = authMethods else { return }

        switch authMethods[indexPath.row].type {
        case .Basic:
            performSegueWithIdentifier(AuthMethodListViewController.showBasicUserAuthSegueId, sender: nil)
        case .Github:
            break
        }
    }
}
