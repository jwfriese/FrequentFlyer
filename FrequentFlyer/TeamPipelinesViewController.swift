import UIKit

class TeamPipelinesViewController: UIViewController {
    @IBOutlet weak var teamPipelinesTableView: UITableView?
    
    var target: Target?
    var teamPipelinesService: TeamPipelinesService?
    
    var pipelines: [Pipeline]?
    
    class var storyboardIdentifier: String {
        get {
            return "TeamPipelines"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let target = target else { return }
        guard let teamPipelinesService = teamPipelinesService else { return }
        
        title = "\(target.name) Pipelines"
        teamPipelinesService.getPipelines(forTarget: target) { pipelines, error in
            self.pipelines = pipelines
            dispatch_async(dispatch_get_main_queue()) {
                self.teamPipelinesTableView?.reloadData()
            }
        }
        teamPipelinesTableView?.dataSource = self
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