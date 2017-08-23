import UIKit.UIViewController
import UIKit.UIButton
import RxSwift
import RxCocoa

class VisibilitySelectionViewController: UIViewController {
    @IBOutlet weak var viewPublicPipelinesButton: RoundedButton?
    @IBOutlet weak var logIntoTeamButton: RoundedButton?

    var concourseURLString: String?

    var teamListService = TeamListService()

    class var storyboardIdentifier: String { get { return "VisibilitySelection" } }
    class var showTeamsSegueId: String { get { return "ShowTeams" } }
    class var setPublicPipelinesAsRootPageSegueId: String { get { return "SetPublicPipelinesAsRootPage" } }

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewPublicPipelinesButton?.setUp(withTitleText: "View Public Pipelines",
                                         titleFont: Style.Fonts.button,
                                         controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                         controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )

        logIntoTeamButton?.setUp(withTitleText: "Log Into a Team",
                                 titleFont: Style.Fonts.button,
                                 controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                 controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        enableButtons()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == VisibilitySelectionViewController.setPublicPipelinesAsRootPageSegueId {
            guard let publicPipelinesViewController = segue.destination as? PublicPipelinesViewController else { return }
            guard let concourseURLString = concourseURLString else { return }
            publicPipelinesViewController.concourseURLString = concourseURLString
        } else if segue.identifier == VisibilitySelectionViewController.showTeamsSegueId {
            guard let teamsViewController = segue.destination as? TeamsViewController else { return }
            guard let concourseURLString = concourseURLString else { return }
            guard let teams = sender as? [String] else { return }
            teamsViewController.concourseURLString = concourseURLString
            teamsViewController.teams = teams
        }
    }

    @IBAction func onLogIntoTeamButtonTapped() {
        guard let concourseURLString = concourseURLString else { return }
        disableButtons()

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

    @IBAction func onViewPublicPipelinesButtonTapped() {
        disableButtons()
    }

    private func handleTeamListServiceSuccess(withTeams teams: [String]) {
        if teams.count > 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: VisibilitySelectionViewController.showTeamsSegueId, sender: teams)
            }
        } else {
            let alert = UIAlertController(
                title: "No Teams",
                message: "Could not find any teams for this Concourse instance.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true) {
                    self.enableButtons()
                }
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
            self.present(alert, animated: true) {
                self.enableButtons()
            }
        }
    }

    private func enableButtons() {
        self.viewPublicPipelinesButton?.isEnabled = true
        self.logIntoTeamButton?.isEnabled = true
    }

    private func disableButtons() {
        self.viewPublicPipelinesButton?.isEnabled = false
        self.logIntoTeamButton?.isEnabled = false
    }
}
