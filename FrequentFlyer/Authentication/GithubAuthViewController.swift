import UIKit

class GithubAuthViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var openGithubAuthPageButton: UIButton?
    @IBOutlet weak var tokenTextField: UITextField?
    @IBOutlet weak var stayLoggedInSwitch: UISwitch?
    @IBOutlet weak var submitButton: UIButton?

    var concourseURLString: String?
    var githubAuthURLString: String?
    var keychainWrapper: KeychainWrapper?
    var browserAgent: BrowserAgent?
    var tokenValidationService: TokenValidationService?
    var userTextInputPageOperator: UserTextInputPageOperator?

    class var storyboardIdentifier: String { get { return "GithubAuth" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        tokenTextField?.delegate = self
        submitButton?.enabled = false
        userTextInputPageOperator?.delegate = self
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == GithubAuthViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destinationViewController as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService
        }
    }

    @IBAction func openGithubAuthPageButtonTapped() {
        guard let githubAuthURLString = githubAuthURLString else { return }
        guard let browserAgent = browserAgent else { return }

        guard let url = NSURL(string: githubAuthURLString) else { return }
        browserAgent.openInBrowser(url)
    }

    @IBAction func submitButtonTapped() {
        guard let concourseURLString = concourseURLString else { return }
        guard let tokenValidationService = tokenValidationService else { return }
        guard let tokenString = tokenTextField?.text else { return }
        guard let keychainWrapper = keychainWrapper else { return }

        tokenValidationService.validate(token: Token(value: tokenString), forConcourse: concourseURLString) { error in
            if let error = error {
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: error.details,
                                              preferredStyle: .Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                let token = Token(value: tokenString)
                let newTarget = Target(name: "target",
                                       api: concourseURLString,
                                       teamName: "main",
                                       token: token)
                if self.stayLoggedInSwitch != nil && self.stayLoggedInSwitch!.on {
                    keychainWrapper.saveTarget(newTarget)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier(GithubAuthViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }
}

extension GithubAuthViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        submitButton?.enabled = tokenTextField?.text != ""
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        submitButton?.enabled = false
        return true
    }
}

extension GithubAuthViewController: UserTextInputPageDelegate {
    var textFields: [UITextField] { get { return [tokenTextField!] } }
    var pageView: UIView { get { return view } }
    var pageScrollView: UIScrollView { get { return scrollView! } }
}
