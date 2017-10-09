import UIKit
import RxSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var usernameField: TitledTextField?
    @IBOutlet weak var passwordField: TitledTextField?
    @IBOutlet weak var stayLoggedInToggle: TitledCheckBox?
    @IBOutlet weak var basicAuthLoginButton: RoundedButton?
    @IBOutlet weak var gitHubAuthDisplayLabel: UILabel?
    @IBOutlet weak var gitHubAuthButton: RoundedButton?

    var basicAuthTokenService = BasicAuthTokenService()
    var keychainWrapper = KeychainWrapper()
    var userTextInputPageOperator = UserTextInputPageOperator()

    var concourseURLString: String?
    var teamName: String?
    var authMethods: [AuthMethod]?

    var token$: Observable<Token>?
    var disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "Login" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }
    class var showGitHubAuthSegueId: String { get { return "ShowGitHubAuth" } }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LoginViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let pipelinesViewController = segue.destination as? PipelinesViewController else {
                return
            }

            pipelinesViewController.target = target

            let pipelinesService = PipelinesService()
            pipelinesService.httpClient = HTTPClient()
            pipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            pipelinesViewController.pipelinesService = pipelinesService

            pipelinesViewController.keychainWrapper = KeychainWrapper()
        } else if segue.identifier == LoginViewController.showGitHubAuthSegueId {
            guard let gitHubAuthViewController = segue.destination as? GitHubAuthViewController else {
                return
            }

            guard let gitHubAuthURLString = sender as? String else { return }
            gitHubAuthViewController.gitHubAuthURLString = gitHubAuthURLString

            guard let concourseURLString = concourseURLString else { return }
            gitHubAuthViewController.concourseURLString = concourseURLString

            guard let teamName = teamName else { return }
            gitHubAuthViewController.teamName = teamName

            gitHubAuthViewController.keychainWrapper = KeychainWrapper()
            gitHubAuthViewController.httpSessionUtils = HTTPSessionUtils()

            let tokenValidationService = TokenValidationService()
            tokenValidationService.httpClient = HTTPClient()
            gitHubAuthViewController.tokenValidationService = tokenValidationService

            gitHubAuthViewController.userTextInputPageOperator = UserTextInputPageOperator()
        }
    }

    @IBAction func submitButtonTapped() {
        guard let username = usernameField?.textField?.text else { return }
        guard let password = passwordField?.textField?.text else { return }
        guard let concourseURL = concourseURLString else { return }
        guard let teamName = teamName else { return }

        basicAuthLoginButton?.isEnabled = false

        token$ = basicAuthTokenService.getToken(forTeamWithName: teamName,
                                                concourseURL: concourseURL,
                                                username: username,
                                                password: password
        )

        token$!.subscribe(
            onNext: { token in
                let newTarget = Target(name: "target",
                                       api: concourseURL,
                                       teamName: teamName,
                                       token: token)
                if self.stayLoggedInToggle != nil && self.stayLoggedInToggle!.checkBox!.on {
                    self.keychainWrapper.saveTarget(newTarget)
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: LoginViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
        },
            onError: { error in
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: "Please check that the username and password you entered are correct.",
                                              preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.basicAuthLoginButton?.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
        },
            onCompleted: nil,
            onDisposed: nil
        )
            .disposed(by: disposeBag)
    }

    @IBAction func gitHubAuthButtonTapped() {
        if let gitHubAuthDefinition = authMethods?.first(where: { method in
            return method.type == .gitHub
        }) {
            self.gitHubAuthButton?.isEnabled = false
            performSegue(withIdentifier: LoginViewController.showGitHubAuthSegueId, sender: gitHubAuthDefinition.url)
        }
    }
}

// MARK: - Lifecycle
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let authMethods = authMethods else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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
            userTextInputPageOperator.delegate = self
        } else {
            usernameField?.isHidden = true
            passwordField?.isHidden = true
            stayLoggedInToggle?.isHidden = true
            basicAuthLoginButton?.isHidden = true
        }

        let doesProvideGitHubAuth = authMethods.contains(where: { method in return method.type == .gitHub })
        if doesProvideGitHubAuth {
            gitHubAuthButton?.setUp(withTitleText: "Log in with GitHub",
                                    titleFont: Style.Fonts.button,
                                    controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                    controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
            )
        } else {
            gitHubAuthButton?.isHidden = true
            gitHubAuthDisplayLabel?.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        gitHubAuthButton?.isEnabled = true
    }
}

extension LoginViewController: UserTextInputPageDelegate {
    var pageView: UIView { get { return view } }
    var pageScrollView: UIScrollView { get { return scrollView! } }

    var textFields: [UITextField] {
        get { return [usernameField!.textField!, passwordField!.textField!] }
    }
}
