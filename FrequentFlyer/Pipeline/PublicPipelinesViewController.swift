import UIKit.UIViewController
import RxSwift
import RxCocoa

class PublicPipelinesViewController: UIViewController {
    @IBOutlet weak var pipelinesTableView: UITableView?
    @IBOutlet weak var gearBarButtonItem: UIBarButtonItem?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var publicPipelinesTableViewDataSource = PublicPipelinesTableViewDataSource()
    var publicPipelinesDataStreamProducer = PublicPipelinesDataStreamProducer()
    var teamListService = TeamListService()

    var concourseURLString: String?
    var pipelines: [Pipeline]?

    var disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "PublicPipelines" } }
    class var showTeamsSegueId: String { get { return "ShowTeams" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let concourseURLString = concourseURLString else { return }

        title = "Pipelines"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        setUpCellPopulation(withConcourseURL: concourseURLString)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PublicPipelinesViewController.showTeamsSegueId {
            guard let teamsViewController = segue.destination as? TeamsViewController else { return }
            guard let concourseURLString = concourseURLString else { return }
            guard let teams = sender as? [String] else { return }
            teamsViewController.concourseURLString = concourseURLString
            teamsViewController.teams = teams
        }
    }

    private func setUpCellPopulation(withConcourseURL concourseURL: String) {
        guard let pipelinesTableView = pipelinesTableView else { return }

        pipelinesTableView.separatorStyle = .none
        loadingIndicator?.startAnimating()
        publicPipelinesTableViewDataSource.setUp()
        publicPipelinesDataStreamProducer.openStream(forConcourseWithURL: concourseURL)
            .do(onNext: self.onNext(),
                onError: self.onError()
            )
            .bind(to: pipelinesTableView.rx.items(dataSource: publicPipelinesTableViewDataSource))
            .disposed(by: disposeBag)
        pipelinesTableView.rx.setDelegate(publicPipelinesTableViewDataSource)
            .disposed(by: disposeBag)
    }

    private func onNext() -> ([PipelineGroupSection]) -> () {
        return { _ in
            DispatchQueue.main.async {
                self.pipelinesTableView?.separatorStyle = .singleLine
                self.loadingIndicator?.stopAnimating()
            }
        }
    }

    private func onError() -> (Error) -> () {
        return { _ in
            let alert = UIAlertController(
                title: "Error",
                message: "An unexpected error has occurred. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil
                )
            )

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                self.pipelinesTableView?.separatorStyle = .singleLine
                self.loadingIndicator?.stopAnimating()
            }
        }
    }

    @IBAction func gearTapped() {
        let optionsActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionsActionSheet.addAction(
            UIAlertAction(
                title: "Log Into a Team",
                style: .default,
                handler: { _ in
                    self.fireOffTeamListCall()
            }
            )
        )

        optionsActionSheet.addAction(
            UIAlertAction(
                title: "Select a Concourse",
                style: .default,
                handler: { _ in
                    self.performSegue(withIdentifier: PublicPipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
            }
            )
        )

        optionsActionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .default,
                handler: nil
            )
        )

        DispatchQueue.main.async {
            self.present(optionsActionSheet, animated: true, completion: nil)
        }
    }

    private func fireOffTeamListCall() {
        guard let concourseURL = concourseURLString else { return }
        teamListService.getTeams(forConcourseWithURL: concourseURL)
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
                self.performSegue(withIdentifier: PublicPipelinesViewController.showTeamsSegueId, sender: teams)
            }
        } else {
            let alert = UIAlertController(
                title: "No Teams",
                message: "Could not find any teams for this Concourse instance.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
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
        }
    }
}
