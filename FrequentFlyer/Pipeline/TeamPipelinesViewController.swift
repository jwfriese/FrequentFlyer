import UIKit

class TeamPipelinesViewController: UIViewController {
    @IBOutlet weak var teamPipelinesTableView: UITableView?
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem?

    var teamPipelinesService = TeamPipelinesService()
    var keychainWrapper = KeychainWrapper()

    var target: Target?

    var pipelines: [Pipeline]?

    class var storyboardIdentifier: String { get { return "TeamPipelines" } }
    class var showBuildsSegueId: String { get { return "ShowBuilds" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let target = target else { return }

        title = "Pipelines"
        teamPipelinesService.getPipelines(forTarget: target) { pipelines, error in
            self.pipelines = pipelines
            DispatchQueue.main.async {
                self.teamPipelinesTableView?.reloadData()
            }
        }

        teamPipelinesTableView?.dataSource = self
        teamPipelinesTableView?.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamPipelinesViewController.showBuildsSegueId {
            guard let buildsViewController = segue.destination as? BuildsViewController else { return  }
            guard let indexPath = sender as? IndexPath else { return }
            guard let pipeline = pipelines?[indexPath.row] else { return }
            guard let target = target else { return }

            buildsViewController.pipeline = pipeline
            buildsViewController.target = target

            let buildsService = BuildsService()
            buildsService.httpClient = HTTPClient()
            buildsService.buildsDataDeserializer = BuildsDataDeserializer()
            buildsViewController.buildsService = buildsService
        } else if segue.identifier == TeamPipelinesViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destination as? ConcourseEntryViewController else {
                return
            }

            concourseEntryViewController.userTextInputPageOperator = UserTextInputPageOperator()

            let authMethodsService = AuthMethodsService()
            authMethodsService.httpClient = HTTPClient()
            authMethodsService.authMethodsDataDeserializer = AuthMethodDataDeserializer()
            concourseEntryViewController.authMethodsService = authMethodsService

            let unauthenticatedTokenService = UnauthenticatedTokenService()
            unauthenticatedTokenService.httpClient = HTTPClient()
            unauthenticatedTokenService.tokenDataDeserializer = TokenDataDeserializer()
            concourseEntryViewController.unauthenticatedTokenService = unauthenticatedTokenService

            concourseEntryViewController.navigationItem.hidesBackButton = true
        }
    }

    @IBAction func logoutTapped() {
        keychainWrapper.deleteTarget()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: TeamPipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
        }
    }
}

extension TeamPipelinesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pipelines = pipelines else { return 0 }
        return pipelines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamPipelinesTableView?.dequeueReusableCell(withIdentifier: PipelineTableViewCell.cellReuseIdentifier, for: indexPath) as! PipelineTableViewCell
        cell.nameLabel?.text = pipelines?[indexPath.row].name
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension TeamPipelinesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: TeamPipelinesViewController.showBuildsSegueId, sender: indexPath)
    }
}
