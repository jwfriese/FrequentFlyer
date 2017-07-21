import UIKit

class JobDetailViewController: UIViewController {
    var triggerBuildService = TriggerBuildService()

    var target: Target?
    var pipeline: Pipeline?
    var job: Job?

    class var storyboardIdentifier: String { get { return "JobDetail" } }
    class var embedJobControlPanelSegueId: String { get { return "EmbedBuildControlPanel" } }
    class var embedLogsSegueId: String { get { return "EmbedLogs" } }

    weak var controlPanel: BuildControlPanelViewController? {
        return childViewControllers.first { controller in
            return controller is BuildControlPanelViewController
            } as? BuildControlPanelViewController
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

        if let nextBuild = job.nextBuild {
            controlPanel.setBuild(nextBuild)
            logsPane.build = nextBuild
        } else if let finishedBuild = job.finishedBuild {
            controlPanel.setBuild(finishedBuild)
            logsPane.build = finishedBuild
        }

        controlPanel.target = target
        controlPanel.pipeline = pipeline

        logsPane.target = target
        logsPane.fetchLogs()
    }
}
