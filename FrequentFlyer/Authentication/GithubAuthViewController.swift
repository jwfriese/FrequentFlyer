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
        submitButton?.isEnabled = false
        userTextInputPageOperator?.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GithubAuthViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destination as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService

            teamPipelinesViewController.keychainWrapper = KeychainWrapper()
        }
    }

    @IBAction func openGithubAuthPageButtonTapped() {
        guard let githubAuthURLString = githubAuthURLString else { return }
        guard let browserAgent = browserAgent else { return }

        guard let url = URL(string: githubAuthURLString) else { return }
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
                                              preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let token = Token(value: tokenString)
                let newTarget = Target(name: "target",
                                       api: concourseURLString,
                                       teamName: "main",
                                       token: token)
                if self.stayLoggedInSwitch != nil && self.stayLoggedInSwitch!.isOn {
                    keychainWrapper.saveTarget(newTarget)
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: GithubAuthViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }
}

extension GithubAuthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        submitButton?.isEnabled = tokenTextField?.text != ""
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        submitButton?.isEnabled = false
        return true
    }
}

extension GithubAuthViewController: UserTextInputPageDelegate {
    var textFields: [UITextField] { get { return [tokenTextField!] } }
    var pageView: UIView { get { return view } }
    var pageScrollView: UIScrollView { get { return scrollView! } }
}
