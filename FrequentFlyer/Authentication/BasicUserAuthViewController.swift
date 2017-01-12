import UIKit

class BasicUserAuthViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var stayLoggedInSwitch: UISwitch?
    @IBOutlet weak var submitButton: UIButton?

    var basicAuthTokenService = BasicAuthTokenService()
    var keychainWrapper = KeychainWrapper()
    var concourseURLString: String?

    class var storyboardIdentifier: String { get { return "BasicUserAuth" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        usernameTextField?.delegate = self
        passwordTextField?.delegate = self
        submitButton?.isEnabled = false
    }

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
        guard let username = usernameTextField?.text else { return }
        guard let password = passwordTextField?.text else { return }
        guard let concourseURL = concourseURLString else { return }

        submitButton?.isEnabled = false

        basicAuthTokenService.getToken(forTeamWithName: "main", concourseURL: concourseURL, username: username, password: password) { token, error in
            if let error = error {
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: error.details,
                                              preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.submitButton?.isEnabled = true
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
                    self.performSegue(withIdentifier: ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                }
            }
        }
    }
}

extension BasicUserAuthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === usernameTextField {
            if string != "" {
                submitButton?.isEnabled = passwordTextField?.text != ""
            } else {
                submitButton?.isEnabled = false
            }
        } else if textField === passwordTextField {
            if string != "" {
                submitButton?.isEnabled = usernameTextField?.text != ""
            } else {
                submitButton?.isEnabled = false
            }
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        submitButton?.isEnabled = false
        return true
    }
}
