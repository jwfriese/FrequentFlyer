import UIKit

class TeamPipelinesViewController: UIViewController {
    @IBOutlet weak var teamPipelinesTableView: UITableView?
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem?

    var target: Target?
    var teamPipelinesService: TeamPipelinesService?
    var keychainWrapper: KeychainWrapper?

    var pipelines: [Pipeline]?

    class var storyboardIdentifier: String { get { return "TeamPipelines" } }
    class var showBuildsSegueId: String { get { return "ShowBuilds" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let target = target else { return }
        guard let teamPipelinesService = teamPipelinesService else { return }

        title = "Pipelines"
        teamPipelinesService.getPipelines(forTarget: target) { pipelines, error in
            self.pipelines = pipelines
            dispatch_async(dispatch_get_main_queue()) {
                self.teamPipelinesTableView?.reloadData()
            }
        }

        teamPipelinesTableView?.dataSource = self
        teamPipelinesTableView?.delegate = self
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == TeamPipelinesViewController.showBuildsSegueId {
            guard let buildsViewController = segue.destinationViewController as? BuildsViewController else { return  }
            guard let indexPath = sender as? NSIndexPath else { return }
            guard let pipeline = pipelines?[indexPath.row] else { return }
            guard let target = target else { return }

            buildsViewController.pipeline = pipeline
            buildsViewController.target = target

            let buildsService = BuildsService()
            buildsService.httpClient = HTTPClient()
            buildsService.buildsDataDeserializer = BuildsDataDeserializer()
            buildsViewController.buildsService = buildsService
        } else if segue.identifier == TeamPipelinesViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destinationViewController as? ConcourseEntryViewController else {
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
        guard let keychainWrapper = keychainWrapper else { return }
        keychainWrapper.deleteTarget()
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(TeamPipelinesViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
        }
    }
}

extension TeamPipelinesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pipelines = pipelines else { return 0 }
        return pipelines.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamPipelinesTableView?.dequeueReusableCellWithIdentifier(PipelineTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! PipelineTableViewCell
        cell.nameLabel?.text = pipelines?[indexPath.row].name
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension TeamPipelinesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(TeamPipelinesViewController.showBuildsSegueId, sender: indexPath)
    }
}
