import UIKit

class TargetListViewController: UIViewController {
    @IBOutlet weak var targetListTableView: UITableView?

    var targetListService: TargetListService?

    var targetList: [Target]?

    class var storyboardIdentifier: String { get { return "TargetList" } }
    class var showAddTargetSegueId: String { get { return "ShowAddTarget" } }
    class var showTargetBuildsSegueId: String { get { return "ShowTeamPipelines" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let targetListService = targetListService else { return }

        targetListTableView?.dataSource = self
        targetListTableView?.delegate = self
        targetList = targetListService.getTargetList()

        title = "Targets"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == TargetListViewController.showAddTargetSegueId {
            if let addTargetViewController = segue.destinationViewController as? AddTargetViewController {
                addTargetViewController.addTargetDelegate = self

                let unauthenticatedTokenService = UnauthenticatedTokenService()
                unauthenticatedTokenService.httpClient = HTTPClient()
                unauthenticatedTokenService.tokenDataDeserializer = TokenDataDeserializer()
                addTargetViewController.unauthenticatedTokenService = unauthenticatedTokenService

                let authMethodsService = AuthMethodsService()
                authMethodsService.httpClient = HTTPClient()
                authMethodsService.authMethodsDataDeserializer = AuthMethodDataDeserializer()
                addTargetViewController.authMethodsService = authMethodsService
            }
        } else if segue.identifier == TargetListViewController.showTargetBuildsSegueId {
            if let teamPipelinesViewController = segue.destinationViewController as? TeamPipelinesViewController {
                teamPipelinesViewController.target = (sender as? Target)

                let teamPipelinesService = TeamPipelinesService()
                teamPipelinesService.httpClient = HTTPClient()
                teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
                teamPipelinesViewController.teamPipelinesService = teamPipelinesService
            }
        }
    }
}

extension TargetListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let targetList = targetList else { return 0 }
        return targetList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TargetListTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! TargetListTableViewCell
        cell.targetNameLabel?.text = targetList![indexPath.row].name

        return cell
    }
}

extension TargetListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(TargetListViewController.showTargetBuildsSegueId,
                                   sender: targetList?[indexPath.row]
        )
    }
}

extension TargetListViewController: AddTargetDelegate {
    func onTargetAdded(target: Target) {
        targetList?.append(target)
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.popToViewController(self, animated: true)
            self.targetListTableView?.reloadData()
        }
    }
}
