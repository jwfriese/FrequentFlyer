import UIKit

class BuildsViewController: UIViewController {
    @IBOutlet weak var buildsTableView: UITableView?
    @IBOutlet weak var buildsTableHeaderView: BuildsTableViewHeaderView?

    var pipeline: Pipeline?
    var target: Target?
    var buildsService: BuildsService?

    var builds: [Build]?

    class var storyboardIdentifier: String { get { return "Builds" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pipeline = pipeline else { return }
        guard let target = target else { return }
        guard let buildsService = buildsService else { return }

        title = "\(pipeline.name) Builds"
        buildsTableView?.dataSource = self
        buildsTableView?.delegate = self

        buildsService.getBuilds(forTarget: target) { builds, error in
            var buildsForPipeline: [Build]?
            if let builds = builds {
                buildsForPipeline = builds.filter { build in
                    return build.pipelineName == self.pipeline?.name
                }
            }

            self.builds = buildsForPipeline
            dispatch_async(dispatch_get_main_queue()) {
                self.buildsTableView?.reloadData()
            }
        }
    }
}

extension BuildsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let builds = builds else { return 0 }
        return builds.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = buildsTableView?.dequeueReusableCellWithIdentifier(BuildTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! BuildTableViewCell
        let build = builds?[indexPath.row]

        if let buildId = build?.id {
            cell.idLabel?.text = String(buildId)
        }

        cell.jobNameLabel?.text = build?.jobName
        cell.statusLabel?.text = build?.status

        return cell
    }
}

extension BuildsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return buildsTableHeaderView
    }
}
