import UIKit
import RxSwift
import RxCocoa

class ConcourseEntryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var concourseURLEntryField: TitledTextField?
    @IBOutlet weak var submitButton: RoundedButton?

    var authMethodsService = AuthMethodsService()
    var unauthenticatedTokenService = UnauthenticatedTokenService()
    var userTextInputPageOperator = UserTextInputPageOperator()

    class var storyboardIdentifier: String { get { return "ConcourseEntry" } }
    class var showLoginSegueId: String { get { return "ShowLogin" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }
    class var showGitHubAuthSegueId: String { get { return "ShowGitHubAuth" } }

    var authMethod$: Observable<AuthMethod>?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        view?.backgroundColor = Style.Colors.backgroundColor
        scrollView?.backgroundColor = Style.Colors.backgroundColor
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        submitButton?.setUp(withTitleText: "Submit",
                            titleFont: Style.Fonts.button,
                            controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                            controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )

        concourseURLEntryField?.titleLabel?.text = "URL"

        concourseURLEntryField?.textField?.autocorrectionType = .no
        concourseURLEntryField?.textField?.keyboardType = .URL

        concourseURLEntryField?.textField?.delegate = self
        submitButton?.isEnabled = false

        userTextInputPageOperator.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConcourseEntryViewController.showLoginSegueId {
            guard let loginViewController = segue.destination as? LoginViewController else {
                return
            }

            guard let concourseURLString = concourseURLEntryField?.textField?.text else { return }
            guard let authMethods = sender as? [AuthMethod] else { return }

            loginViewController.authMethods = authMethods
            loginViewController.concourseURLString = concourseURLString
        } else if segue.identifier == ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destination as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService
        } else if segue.identifier == ConcourseEntryViewController.showGitHubAuthSegueId {
            guard let gitHubAuthMethod = sender as? AuthMethod else { return }
            guard let gitHubAuthViewController = segue.destination as? GitHubAuthViewController else { return }
            guard let concourseURLString = concourseURLEntryField?.textField?.text else { return }

            gitHubAuthViewController.concourseURLString = concourseURLString
            gitHubAuthViewController.gitHubAuthURLString = gitHubAuthMethod.url
        }
    }

    @IBAction func submitButtonTapped() {
        guard var concourseURLString = concourseURLEntryField?.textField?.text else { return }

        let inputHasProtocol = concourseURLString.hasPrefix("http://") || concourseURLString.hasPrefix("https://")
        if !inputHasProtocol {
            concourseURLString = "https://" + concourseURLString
        }

        submitButton?.isEnabled = false

        authMethod$ = authMethodsService.getMethods(forTeamName: "main", concourseURL: concourseURLString)
        authMethod$?.toArray().subscribe(
            onNext: { authMethods in
                guard authMethods.count > 0 else {
                    self.handleAuthMethodsError(concourseURLString)
                    return
                }

                var segueIdentifier: String!
                var sender: Any!
                if authMethods.count == 1 && authMethods.first!.type == .gitHub {
                    segueIdentifier = ConcourseEntryViewController.showGitHubAuthSegueId
                    sender = authMethods.first!
                } else {
                    segueIdentifier = ConcourseEntryViewController.showLoginSegueId
                    sender = authMethods
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: segueIdentifier, sender: sender)
                }
        },
            onError: { _ in
                self.handleAuthMethodsError(concourseURLString)
        })
            .addDisposableTo(self.disposeBag)
    }

    private func handleAuthMethodsError(_ concourseURLString: String) {
        unauthenticatedTokenService.getUnauthenticatedToken(forTeamName: "main", concourseURL: concourseURLString)
            .subscribe(
                onNext: { token in
                    let newTarget = Target(name: "target",
                                           api: concourseURLString,
                                           teamName: "main",
                                           token: token)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                    }

            },
                onError: { error in
                    let alert = UIAlertController(title: "Authorization Failed",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.submitButton?.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
            },
                onCompleted: nil,
                onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}

extension ConcourseEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isDeleting = string == ""
        let isCurrentStringLongerThanOne = textField.text != nil && textField.text!.characters.count > 1
        let willHaveText = !isDeleting || isCurrentStringLongerThanOne
        submitButton?.isEnabled = willHaveText
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        submitButton?.isEnabled = false
        return true
    }
}

extension ConcourseEntryViewController: UserTextInputPageDelegate {
    var textFields: [UITextField] { get { return [concourseURLEntryField!.textField!] } }
    var pageView: UIView { get { return view } }
    var pageScrollView: UIScrollView { get { return scrollView! } }
}
