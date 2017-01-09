import UIKit

class ConcourseEntryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var concourseURLEntryField: UITextField?
    @IBOutlet weak var submitButton: UIButton?

    var authMethodsService = AuthMethodsService()
    var unauthenticatedTokenService = UnauthenticatedTokenService()
    var userTextInputPageOperator = UserTextInputPageOperator()

    class var storyboardIdentifier: String { get { return "ConcourseEntry" } }
    class var showAuthMethodListSegueId: String { get { return "ShowAuthMethodList" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        concourseURLEntryField?.autocorrectionType = .no
        concourseURLEntryField?.keyboardType = .URL

        concourseURLEntryField?.delegate = self
        submitButton?.isEnabled = false

        userTextInputPageOperator.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConcourseEntryViewController.showAuthMethodListSegueId {
            guard let authMethodListViewController = segue.destination as? AuthMethodListViewController else {
                return
            }

            guard let concourseURLString = concourseURLEntryField?.text else { return }
            guard let authMethodWrapper = sender as? ArrayWrapper<AuthMethod> else { return }

            authMethodListViewController.authMethods = authMethodWrapper.array
            authMethodListViewController.concourseURLString = concourseURLString
        }
        else if segue.identifier == ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destination as? TeamPipelinesViewController else {
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
        guard let concourseURLString = concourseURLEntryField?.text else { return }

        authMethodsService.getMethods(forTeamName: "main", concourseURL: concourseURLString) { authMethods, error in
            if authMethods == nil || authMethods!.count == 0 {
                self.unauthenticatedTokenService.getUnauthenticatedToken(forTeamName: "main", concourseURL: concourseURLString) { token, error in
                    guard let token = token else {
                        let alert = UIAlertController(title: "Authorization Failed",
                                                      message: error?.details,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }

                        return
                    }

                    let newTarget = Target(name: "target",
                                           api: concourseURLString,
                                           teamName: "main",
                                           token: token)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let wrappedAuthMethods = ArrayWrapper<AuthMethod>(array: authMethods!)
                    self.performSegue(withIdentifier: ConcourseEntryViewController.showAuthMethodListSegueId, sender: wrappedAuthMethods)
                }
            }
        }
    }
}

extension ConcourseEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        submitButton?.isEnabled = concourseURLEntryField?.text != ""
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        submitButton?.isEnabled = false
        return true
    }
}

extension ConcourseEntryViewController: UserTextInputPageDelegate {
    var textFields: [UITextField] { get { return [concourseURLEntryField!] } }
    var pageView: UIView { get { return view } }
    var pageScrollView: UIScrollView { get { return scrollView! } }
}
