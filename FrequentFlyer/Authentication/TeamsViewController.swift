import UIKit
import RxSwift
import RxCocoa

class TeamsViewController: UIViewController {
    @IBOutlet weak var teamsTableView: UITableView?

    var authMethodsService = AuthMethodsService()
    var unauthenticatedTokenService = UnauthenticatedTokenService()

    var concourseURLString: String?
    var teams: [String]?

    var selectedTeamName: String!
    let disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "Teams" } }
    class var showLoginSegueId: String { get { return "ShowLogin" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }
    class var showGitHubAuthSegueId: String { get { return "ShowGitHubAuth" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let concourseURLString = concourseURLString else { return }
        guard let teams = teams else { return }
        guard let teamsTableView = teamsTableView else { return }

        title = "Teams"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        Observable.just(teams)
            .bind(to: teamsTableView.rx.items(
                cellIdentifier: TeamTableViewCell.cellReuseIdentifier,
                cellType: TeamTableViewCell.self)) { (row, teamName, cell) in
                    cell.teamLabel?.text = teamName
            }
            .disposed(by: disposeBag)

        teamsTableView.rx.modelSelected(String.self)
            .flatMap { teamName in
                self.doAuthMethodsCall(forTeamName: teamName, concourseURLString: concourseURLString)
            }
            .subscribe(onNext: { authMethods in
                guard authMethods.count > 0 else {
                    self.attemptUnauthenticatedLogin(forTeamName: self.selectedTeamName, concourseURLString: concourseURLString)
                    return
                }

                if authMethods.count == 1 && authMethods.first!.type == .uaa {
                    let errorMessage = "The app does not support UAA yet."
                    self.presentErrorAlert(withTitle: "Unsupported Auth Method", message: errorMessage)
                    return
                }

                var segueIdentifier: String!
                var sender: Any!
                if self.isGitHubAuthTheOnlySupportedAuthType(inAuthMethodCollection: authMethods) {
                    segueIdentifier = TeamsViewController.showGitHubAuthSegueId
                    sender = authMethods.first!
                } else {
                    segueIdentifier = TeamsViewController.showLoginSegueId
                    sender = authMethods
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: segueIdentifier, sender: sender)
                }
            },
                       onError: { _ in
                        let errorMessage = "Encountered error when trying to fetch Concourse auth methods. Please check your Concourse configuration and try again later."
                        self.presentErrorAlert(withTitle: "Error", message: errorMessage)
            })
            .addDisposableTo(disposeBag)
    }

    private func isGitHubAuthTheOnlySupportedAuthType(inAuthMethodCollection authMethods: [AuthMethod]) -> Bool {
        let authMethodsWithoutUAA = authMethods.filter { authMethod in
            return authMethod.type != .uaa
        }

        return authMethodsWithoutUAA.count == 1 && authMethodsWithoutUAA.first!.type == .gitHub
    }

    private func doAuthMethodsCall(forTeamName teamName: String, concourseURLString: String) -> Observable<[AuthMethod]> {
        selectedTeamName = teamName
        return authMethodsService.getMethods(forTeamName: teamName, concourseURL: concourseURLString)
    }

    private func presentErrorAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamsViewController.showLoginSegueId {
            guard let loginViewController = segue.destination as? LoginViewController else { return }
            guard let concourseURLString = concourseURLString else { return }
            guard let authMethods = sender as? [AuthMethod] else { return }

            loginViewController.authMethods = authMethods
            loginViewController.concourseURLString = concourseURLString
        } else if segue.identifier == TeamsViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destination as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService
        } else if segue.identifier == TeamsViewController.showGitHubAuthSegueId {
            guard let gitHubAuthMethod = sender as? AuthMethod else { return }
            guard let gitHubAuthViewController = segue.destination as? GitHubAuthViewController else { return }
            guard let concourseURLString = concourseURLString else { return }

            gitHubAuthViewController.concourseURLString = concourseURLString
            gitHubAuthViewController.gitHubAuthURLString = gitHubAuthMethod.url
        }
    }

    private func attemptUnauthenticatedLogin(forTeamName teamName: String, concourseURLString: String) {
        unauthenticatedTokenService.getUnauthenticatedToken(forTeamName: teamName, concourseURL: concourseURLString)
            .subscribe(
                onNext: { token in
                    let newTarget = Target(name: "target",
                                           api: concourseURLString,
                                           teamName: teamName,
                                           token: token)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: TeamsViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                    }

            },
                onError: { error in
                    let alert = UIAlertController(title: "Error",
                                                  message: "Failed to fetch authentication methods and failed to fetch a token without credentials.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
            },
                onCompleted: nil,
                onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}
