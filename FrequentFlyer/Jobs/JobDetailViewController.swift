import UIKit

class JobDetailViewController: UIViewController {
    var triggerBuildService = TriggerBuildService()

    var target: Target?
    var pipeline: Pipeline?
    var job: Job?

    class var storyboardIdentifier: String { get { return "JobDetail" } }

    weak var controlPanel: JobControlPanelViewController? {
        return childViewControllers.first as? JobControlPanelViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controlPanel = controlPanel else { return }
        guard let target = target else { return }
        guard let pipeline = pipeline else { return }
        guard let job = job else { return }
        guard let latestBuild = job.builds.first else { return }

        title = job.name

        controlPanel.target = target
        controlPanel.pipeline = pipeline
        controlPanel.job = job
        controlPanel.latestJobNameLabel?.text = latestBuild.name
        controlPanel.latestJobStatusLabel?.text = latestBuild.status
    }
}
