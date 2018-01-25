import UIKit
import RxSwift
import RxCocoa

class ConcourseEntryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var concourseURLEntryField: TitledTextField?
    @IBOutlet weak var submitButton: RoundedButton?

    var infoService = InfoService()
    var sslTrustService = SSLTrustService()
    var userTextInputPageOperator = UserTextInputPageOperator()

    class var storyboardIdentifier: String { get { return "ConcourseEntry" } }
    class var showVisibilitySelectionSegueId: String { get { return "ShowVisibilitySelection" } }

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

        concourseURLEntryField?.titleLabel?.text = "Concourse Base URL"

        concourseURLEntryField?.textField?.autocorrectionType = .no
        concourseURLEntryField?.textField?.keyboardType = .URL

        concourseURLEntryField?.textField?.delegate = self
        submitButton?.isEnabled = false

        userTextInputPageOperator.delegate = self
        sslTrustService.clearAllTrust()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let text = concourseURLEntryField?.textField?.text {
            submitButton?.isEnabled = !text.isEmpty
        } else {
            submitButton?.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConcourseEntryViewController.showVisibilitySelectionSegueId {
            guard let visibilitySelectionViewController = segue.destination as? VisibilitySelectionViewController else { return }
            guard let concourseURLString = concourseURLEntryField?.textField?.text else { return }
            visibilitySelectionViewController.concourseURLString = createValidConcourseURL(fromInput: concourseURLString)
        }
    }

    private func createValidConcourseURL(fromInput input: String) -> String {
        var concourseURLString = input
        let inputHasProtocol = input.hasPrefix("https://")
        if !inputHasProtocol {
            concourseURLString = "https://" + concourseURLString
        }


        return concourseURLString
    }

    @IBAction func submitButtonTapped() {
        guard var concourseURLString = concourseURLEntryField?.textField?.text else { return }
        let inputHasInvalidProtocol = concourseURLString.hasPrefix("http://")
        if inputHasInvalidProtocol {
            showInvalidProtocolAlert()
            return
        }
        if concourseURLString == "https://" {
            showConcourseInaccessibleError(atURL: concourseURLString)
            return
        }

        concourseURLString = createValidConcourseURL(fromInput: concourseURLString)

        submitButton?.isEnabled = false

        checkForConcourseExistence(atBaseURL: concourseURLString)
    }

    private func checkForConcourseExistence(atBaseURL baseURL: String) {
        infoService.getInfo(forConcourseWithURL: baseURL)
            .subscribe(
                onNext: { _ in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: ConcourseEntryViewController.showVisibilitySelectionSegueId, sender: nil)
                    }
            },
                onError: { error in
                    guard let httpError = error as? HTTPError else {
                        self.showConcourseInaccessibleError(atURL: baseURL)
                        return
                    }

                    switch httpError {
                    case .sslValidation:
                        self.showSSLTrustChallenge(forBaseURL: baseURL)
                    }
            })
            .disposed(by: disposeBag)
    }

    private func showSSLTrustChallenge(forBaseURL baseURL: String) {
        let alert = UIAlertController(
            title: "Insecure Connection",
            message: "Could not establish a trusted connection with the Concourse instance. Would you like to connect anyway?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in self.submitButton?.isEnabled = true }))
        alert.addAction(UIAlertAction(title: "Connect", style: .destructive, handler: { _ in
            self.submitButton?.isEnabled = true
            self.sslTrustService.registerTrust(forBaseURL: baseURL)
            self.checkForConcourseExistence(atBaseURL: baseURL)
        }))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showConcourseInaccessibleError(atURL url: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Could not connect to a Concourse at '\(url)'.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            self.submitButton?.isEnabled = true
        }
    }

    private func showInvalidProtocolAlert() {
        let alert = UIAlertController(
            title: "Unsupported Protocol",
            message: "This app does not support connecting to Concourse instances through HTTP. You must use HTTPS.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            self.submitButton?.isEnabled = true
        }
    }
}

extension ConcourseEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isDeleting = string == ""
        let isCurrentStringLongerThanOne = textField.text != nil && textField.text!.count > 1
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
