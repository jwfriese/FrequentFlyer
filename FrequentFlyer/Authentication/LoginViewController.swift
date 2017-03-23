import UIKit
import RxSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: TitledTextField?
    @IBOutlet weak var passwordField: TitledTextField?
    @IBOutlet weak var stayLoggedInToggle: TitledCheckBox?
    @IBOutlet weak var basicAuthLoginButton: RoundedButton?
    @IBOutlet weak var githubAuthDisplayLabel: UILabel?
    @IBOutlet weak var githubAuthButton: RoundedButton?

    var basicAuthTokenService = BasicAuthTokenService()
    var keychainWrapper = KeychainWrapper()

    var concourseURLString: String?
    var authMethods: [AuthMethod]?

    class var storyboardIdentifier: String { get { return "Login" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }
    class var showGithubAuthSegueId: String { get { return "ShowGitHubAuth" } }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LoginViewController.setTeamPipelinesAsRootPageSegueId {
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
        } else if segue.identifier == LoginViewController.showGithubAuthSegueId {
            guard let githubAuthViewController = segue.destination as? GithubAuthViewController else {
                return
            }

            guard let githubAuthURLString = sender as? String else { return }
            githubAuthViewController.githubAuthURLString = githubAuthURLString

            guard let concourseURLString = concourseURLString else { return }
            githubAuthViewController.concourseURLString = concourseURLString

            githubAuthViewController.keychainWrapper = KeychainWrapper()
            githubAuthViewController.httpSessionUtils = HTTPSessionUtils()

            let tokenValidationService = TokenValidationService()
            tokenValidationService.httpClient = HTTPClient()
            githubAuthViewController.tokenValidationService = tokenValidationService

            githubAuthViewController.userTextInputPageOperator = UserTextInputPageOperator()
        }
    }

    @IBAction func submitButtonTapped() {
        guard let username = usernameField?.textField?.text else { return }
        guard let password = passwordField?.textField?.text else { return }
        guard let concourseURL = concourseURLString else { return }

        basicAuthLoginButton?.isEnabled = false

        basicAuthTokenService.getToken(forTeamWithName: "main", concourseURL: concourseURL, username: username, password: password) { token, error in
            if let error = error {
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: error.details,
                                              preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.basicAuthLoginButton?.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
            } else if let token = token {
                let newTarget = Target(name: "target",
                                       api: concourseURL,
                                       teamName: "main",
                                       token: token)
                if self.stayLoggedInToggle != nil && self.stayLoggedInToggle!.checkBox!.on {
                    self.keychainWrapper.saveTarget(newTarget)
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: LoginViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }

    @IBAction func gitHubAuthButtonTapped() {
        if let gitHubAuthDefinition = authMethods?.first(where: { method in
            return method.type == .github
        }) {
            performSegue(withIdentifier: LoginViewController.showGithubAuthSegueId, sender: gitHubAuthDefinition.url)
        }
    }
}

// MARK: - Lifecycle
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let authMethods = authMethods else { return }

        let doesProvideBasicAuth = authMethods.contains(where: { method in return method.type == .basic })
        if doesProvideBasicAuth {
            basicAuthLoginButton?.setUp(withTitleText: "Log in",
                                        titleFont: Style.Fonts.button,
                                        controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                        controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
            )

            usernameField?.titleLabel?.text = "Username"
            passwordField?.titleLabel?.text = "Password"
            stayLoggedInToggle?.titleLabel?.text = "Stay logged in?"
            passwordField?.textField?.isSecureTextEntry = true
        } else {
            usernameField?.isHidden = true
            passwordField?.isHidden = true
            stayLoggedInToggle?.isHidden = true
            basicAuthLoginButton?.isHidden = true
        }

        let doesProvideGitHubAuth = authMethods.contains(where: { method in return method.type == .github })
        if doesProvideGitHubAuth {
            githubAuthButton?.setUp(withTitleText: "Log in with GitHub",
                                    titleFont: Style.Fonts.button,
                                    controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                    controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
            )
        } else {
            githubAuthButton?.isHidden = true
            githubAuthDisplayLabel?.isHidden = true
        }
    }
}
