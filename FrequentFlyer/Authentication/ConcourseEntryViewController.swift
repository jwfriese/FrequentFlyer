import UIKit
import RxSwift
import RxCocoa

class ConcourseEntryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var concourseURLEntryField: TitledTextField?
    @IBOutlet weak var submitButton: RoundedButton?

    var teamListService = TeamListService()
    var authMethodsService = AuthMethodsService()
    var unauthenticatedTokenService = UnauthenticatedTokenService()
    var userTextInputPageOperator = UserTextInputPageOperator()

    class var storyboardIdentifier: String { get { return "ConcourseEntry" } }
    class var showTeamsSegueId: String { get { return "ShowTeams" } }

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

    override func viewDidAppear(_ animated: Bool) {
        if let text = concourseURLEntryField?.textField?.text {
            submitButton?.isEnabled = !text.isEmpty
        } else {
            submitButton?.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConcourseEntryViewController.showTeamsSegueId {
            guard let teamsViewController = segue.destination as? TeamsViewController else { return }
            guard var concourseURLString = concourseURLEntryField?.textField?.text else { return }
            concourseURLString = validatedConcourseURL(fromInput: concourseURLString)

            guard let teams = sender as? [String] else { return }

            teamsViewController.concourseURLString = concourseURLString
            teamsViewController.teams = teams
        }
    }

    private func validatedConcourseURL(fromInput input: String) -> String {
        var concourseURLString = input
        let inputHasProtocol = input.hasPrefix("http://") || input.hasPrefix("https://")
        if !inputHasProtocol {
            concourseURLString = "https://" + concourseURLString
        }

        return concourseURLString
    }

    @IBAction func submitButtonTapped() {
        guard var concourseURLString = concourseURLEntryField?.textField?.text else { return }
        concourseURLString = validatedConcourseURL(fromInput: concourseURLString)

        submitButton?.isEnabled = false

        teamListService.getTeams(forConcourseWithURL: concourseURLString)
            .subscribe(
                onNext: { teams in
                    self.handleTeamListServiceSuccess(withTeams: teams)
            },
                onError: { _ in
                    self.handleTeamListServiceError()
            })
                .addDisposableTo(self.disposeBag)
    }

    private func handleTeamListServiceSuccess(withTeams teams: [String]) {
        if teams.count > 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: ConcourseEntryViewController.showTeamsSegueId, sender: teams)
            }
        } else {
            let alert = UIAlertController(
                title: "No Teams",
                message: "We could find your Concourse instance, but it has no teams to show you.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                self.submitButton?.isEnabled = true
            }
        }
    }

    private func handleTeamListServiceError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Could not connect to a Concourse at the given URL.",
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
