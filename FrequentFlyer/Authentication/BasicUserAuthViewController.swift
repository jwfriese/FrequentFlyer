import UIKit

class BasicUserAuthViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var submitButton: UIButton?

    var basicAuthTokenService: BasicAuthTokenService?
    var concourseURLString: String?
    var keychainWrapper: KeychainWrapper?

    class var storyboardIdentifier: String { get { return "BasicUserAuth" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        usernameTextField?.delegate = self
        passwordTextField?.delegate = self
        submitButton?.enabled = false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == BasicUserAuthViewController.setTeamPipelinesAsRootPageSegueId {
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

    @IBAction func submitButtonTapped() {
        guard let basicAuthTokenService = basicAuthTokenService else { return }
        guard let username = usernameTextField?.text else { return }
        guard let password = passwordTextField?.text else { return }
        guard let concourseURL = concourseURLString else { return }
        guard let keychainWrapper = keychainWrapper else { return }

        basicAuthTokenService.getToken(forTeamWithName: "main", concourseURL: concourseURL, username: username, password: password) { token, error in
            if let error = error {
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: error.details,
                                              preferredStyle: .Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else if let token = token {
                let authInfo = AuthInfo(username: username, token: token)
                keychainWrapper.saveAuthInfo(authInfo, forTargetWithName: "target")
                let newTarget = Target(name: "target",
                                       api: concourseURL,
                                       teamName: "main",
                                       token: token)
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier(ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }
}

extension BasicUserAuthViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === usernameTextField {
            if string != "" {
                submitButton?.enabled = passwordTextField?.text != ""
            } else {
                submitButton?.enabled = false
            }
        } else if textField === passwordTextField {
            if string != "" {
                submitButton?.enabled = usernameTextField?.text != ""
            } else {
                submitButton?.enabled = false
            }
        }

        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        submitButton?.enabled = false
        return true
    }
}
