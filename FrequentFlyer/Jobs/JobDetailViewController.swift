import UIKit

class JobDetailViewController: UIViewController {
    var triggerBuildService = TriggerBuildService()

    var target: Target?
    var pipeline: Pipeline?
    var job: Job?

    class var storyboardIdentifier: String { get { return "JobDetail" } }
    class var embedJobControlPanelSegueId: String { get { return "EmbedJobControlPanel" } }
    class var embedLogsSegueId: String { get { return "EmbedLogs" } }

    weak var controlPanel: JobControlPanelViewController? {
        return childViewControllers.first { controller in
            return controller is JobControlPanelViewController
            } as? JobControlPanelViewController
    }

    weak var logsPane: LogsViewController? {
        return childViewControllers.first { controller in
            return controller is LogsViewController
        } as? LogsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controlPanel = controlPanel else { return }
        guard let logsPane = logsPane else { return }
        guard let target = target else { return }
        guard let pipeline = pipeline else { return }
        guard let job = job else { return }

        title = job.name

        controlPanel.target = target
        controlPanel.pipeline = pipeline
        controlPanel.setJob(job)

        logsPane.build = job.builds.first
        logsPane.target = target
        logsPane.fetchLogs()
    }
}
