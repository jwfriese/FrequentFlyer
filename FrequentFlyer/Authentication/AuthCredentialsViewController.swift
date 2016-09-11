import UIKit

class AuthCredentialsViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var submitButton: UIButton?

    var authCredentialsDelegate: AuthCredentialsDelegate?
    var basicAuthTokenService: BasicAuthTokenService?
    var concourseURLString: String?

    class var storyboardIdentifier: String { get { return "AuthCredentials" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField?.delegate = self
        passwordTextField?.delegate = self
        submitButton?.enabled = false
    }

    @IBAction func submitButtonTapped() {
        guard let basicAuthTokenService = basicAuthTokenService else { return }
        guard let username = usernameTextField?.text else { return }
        guard let password = passwordTextField?.text else { return }
        guard let concourseURL = concourseURLString else { return }
        guard let authCredentialsDelegate = authCredentialsDelegate else { return }

        basicAuthTokenService.getToken(forTeamWithName: "main", concourseURL: concourseURL, username: username, password: password) { token, error in
            if let token = token {
                authCredentialsDelegate.onCredentialsEntered(token)
            }
        }
    }
}

extension AuthCredentialsViewController: UITextFieldDelegate {
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
