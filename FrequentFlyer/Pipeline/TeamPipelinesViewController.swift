import UIKit

class TeamPipelinesViewController: UIViewController {
    @IBOutlet weak var teamPipelinesTableView: UITableView?
    @IBOutlet weak var gearBarButtonItem: UIBarButtonItem?

    var teamPipelinesService = TeamPipelinesService()
    var keychainWrapper = KeychainWrapper()

    var target: Target?

    var pipelines: [Pipeline]?

    class var storyboardIdentifier: String { get { return "TeamPipelines" } }
    class var showJobsSegueId: String { get { return "ShowJobs" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let target = target else { return }

        navigationController?.navigationBar.barTintColor = Style.Colors.navigationBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSFontAttributeName : Style.Fonts.regular(withSize: 18)
        ]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

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
        if segue.identifier == TeamPipelinesViewController.showJobsSegueId {
            guard let jobsViewController = segue.destination as? JobsViewController else { return  }
            guard let indexPath = sender as? IndexPath else { return }
            guard let pipeline = pipelines?[indexPath.row] else { return }
            guard let target = target else { return }

            jobsViewController.pipeline = pipeline
            jobsViewController.target = target
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

    @IBAction func gearTapped() {
        let logOutActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        logOutActionSheet.addAction(
            UIAlertAction(
                title: "Log Out",
                style: .destructive,
                handler: { _ in
                    self.keychainWrapper.deleteTarget()
                    self.performSegue(withIdentifier: TeamPipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
                }
            )
        )

        logOutActionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .default,
                handler: nil
            )
        )

        DispatchQueue.main.async {
            self.present(logOutActionSheet, animated: true, completion: nil)
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
        performSegue(withIdentifier: TeamPipelinesViewController.showJobsSegueId, sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
