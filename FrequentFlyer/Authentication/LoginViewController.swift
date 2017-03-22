import UIKit
import RxSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: TitledTextField?
    @IBOutlet weak var passwordField: TitledTextField?
    @IBOutlet weak var basicAuthLoginButton: RoundedButton?
    @IBOutlet weak var stayLoggedInSwitch: UISwitch?
    @IBOutlet weak var githubAuthDisplayLabel: UILabel?
    @IBOutlet weak var githubAuthButton: UIButton?

    var basicAuthTokenService = BasicAuthTokenService()
    var keychainWrapper = KeychainWrapper()

    var concourseURLString: String?
    var authMethod$: Observable<AuthMethod>!

    class var storyboardIdentifier: String { get { return "Login" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == BasicUserAuthViewController.setTeamPipelinesAsRootPageSegueId {
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
                if self.stayLoggedInSwitch != nil && self.stayLoggedInSwitch!.isOn {
                    self.keychainWrapper.saveTarget(newTarget)
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: LoginViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }
}

// MARK: - Lifecycle
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        basicAuthLoginButton?.setUp(withTitleText: "Log in",
                                    titleFont: Style.Fonts.button,
                                    controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                    controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )

        usernameField?.titleLabel?.text = "Username"
        passwordField?.titleLabel?.text = "Password"
        passwordField?.textField?.isSecureTextEntry = true
    }
}
