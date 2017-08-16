import UIKit

class PipelinesViewController: UIViewController {
    @IBOutlet weak var pipelinesTableView: UITableView?
    @IBOutlet weak var gearBarButtonItem: UIBarButtonItem?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var pipelinesService = PipelinesService()
    var keychainWrapper = KeychainWrapper()

    var target: Target?

    var pipelines: [Pipeline]?

    class var storyboardIdentifier: String { get { return "Pipelines" } }
    class var showJobsSegueId: String { get { return "ShowJobs" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let target = target else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        title = "Pipelines"
        loadingIndicator?.startAnimating()
        pipelinesTableView?.separatorStyle = .none
        pipelinesService.getPipelines(forTarget: target) { pipelines, error in
            if error is AuthorizationError {
                self.handleAuthorizationError()
                return
            }

            if error is UnexpectedError {
                self.handleUnexpectedError()
                return
            }

            guard let pipelines = pipelines else {
                self.handleUnexpectedError()
                return
            }

            self.handlePipelinesReceived(pipelines)
        }

        pipelinesTableView?.dataSource = self
        pipelinesTableView?.delegate = self
    }

    private func handlePipelinesReceived(_ pipelines: [Pipeline]) {
        self.pipelines = pipelines
        DispatchQueue.main.async {
            self.pipelinesTableView?.separatorStyle = .singleLine
            self.pipelinesTableView?.reloadData()
            self.loadingIndicator?.stopAnimating()
        }
    }

    private func handleAuthorizationError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Unauthorized",
                message: "Your credentials have expired. Please authenticate again.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "Log Out",
                    style: .destructive,
                    handler: { _ in
                        self.keychainWrapper.deleteTarget()
                        self.performSegue(withIdentifier: PipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
                }
                )
            )

            self.present(alert, animated: true, completion: nil)
            self.pipelinesTableView?.separatorStyle = .singleLine
            self.pipelinesTableView?.reloadData()
            self.loadingIndicator?.stopAnimating()
        }
    }

    private func handleUnexpectedError() {
        DispatchQueue.main.async {
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

            self.present(alert, animated: true, completion: nil)
            self.pipelinesTableView?.separatorStyle = .singleLine
            self.pipelinesTableView?.reloadData()
            self.loadingIndicator?.stopAnimating()
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PipelinesViewController.showJobsSegueId {
            guard let jobsViewController = segue.destination as? JobsViewController else { return  }
            guard let indexPath = sender as? IndexPath else { return }
            guard let pipeline = pipelines?[indexPath.row] else { return }
            guard let target = target else { return }

            jobsViewController.pipeline = pipeline
            jobsViewController.target = target
        } else if segue.identifier == PipelinesViewController.setConcourseEntryAsRootPageSegueId {
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
                    self.performSegue(withIdentifier: PipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
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

extension PipelinesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pipelines = pipelines else { return 0 }
        return pipelines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pipelinesTableView?.dequeueReusableCell(withIdentifier: PipelineTableViewCell.cellReuseIdentifier, for: indexPath) as! PipelineTableViewCell
        cell.nameLabel?.text = pipelines?[indexPath.row].name
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension PipelinesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: PipelinesViewController.showJobsSegueId, sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
