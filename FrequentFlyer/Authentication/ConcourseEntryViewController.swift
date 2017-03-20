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
    class var showAuthMethodListSegueId: String { get { return "ShowAuthMethodList" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    var authMethod$: Observable<AuthMethod>?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        view?.backgroundColor = Style.Colors.backgroundColor
        scrollView?.backgroundColor = Style.Colors.backgroundColor

        submitButton?.initialize(withTitleText: "Submit",
                                 titleFont: Style.Fonts.button,
                                 controlStateTitleColors: [UIControlState.normal : UIColor.white],
                                 controlStateButtonColors: [UIControlState.normal : Style.Colors.buttonNormal]
        )

        concourseURLEntryField?.titleLabel?.text = "URL"

        concourseURLEntryField?.textField?.autocorrectionType = .no
        concourseURLEntryField?.textField?.keyboardType = .URL

        concourseURLEntryField?.textField?.delegate = self
        submitButton?.isEnabled = false

        userTextInputPageOperator.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConcourseEntryViewController.showAuthMethodListSegueId {
            guard let authMethodListViewController = segue.destination as? AuthMethodListViewController else {
                return
            }

            guard let concourseURLString = concourseURLEntryField?.textField?.text else { return }
            guard let authMethod$ = sender as? Observable<AuthMethod> else { return }

            authMethodListViewController.authMethod$ = authMethod$
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
        guard let concourseURLString = concourseURLEntryField?.textField?.text else { return }

        if concourseURLString.hasPrefix("http://") || concourseURLString.hasPrefix("https://") {
            authMethod$ = authMethodsService.getMethods(forTeamName: "main", concourseURL: concourseURLString)
            authMethod$?.toArray().subscribe(
                onNext: { authMethods in
                    guard authMethods.count > 0 else { self.handleAuthMethodsError(concourseURLString) ; return }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: ConcourseEntryViewController.showAuthMethodListSegueId, sender: self.authMethod$)
                    }
            },
                onError: { _ in
                    self.handleAuthMethodsError(concourseURLString)
            })
                .addDisposableTo(self.disposeBag)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enter a URL that begins with either 'http://' or 'https://'", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    private func handleAuthMethodsError(_ concourseURLString: String) {
        unauthenticatedTokenService.getUnauthenticatedToken(forTeamName: "main", concourseURL: concourseURLString) { token, error in
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
    }
}

extension ConcourseEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        submitButton?.isEnabled = concourseURLEntryField?.textField?.text != ""
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
