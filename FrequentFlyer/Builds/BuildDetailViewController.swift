import UIKit

class BuildDetailViewController: UIViewController {
    @IBOutlet weak var pipelineValueLabel: UILabel?
    @IBOutlet weak var jobValueLabel: UILabel?
    @IBOutlet weak var statusValueLabel: UILabel?
    @IBOutlet weak var retriggerButton: UIButton?
    @IBOutlet weak var viewLogsButton: UIButton?

    var triggerBuildService = TriggerBuildService()

    var build: Build?
    var target: Target?

    class var storyboardIdentifier: String { get { return "BuildDetail" } }
    class var showLogsSegueId: String { get { return "ShowLogs" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let build = build else { return }

        title = "Build #\(build.id)"
        pipelineValueLabel?.text = build.pipelineName
        jobValueLabel?.text = build.jobName
        statusValueLabel?.text = build.status
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == BuildDetailViewController.showLogsSegueId {
            guard let logsViewController = segue.destination as? LogsViewController else {
                return
            }

            let sseService = SSEService()
            sseService.eventSourceCreator = EventSourceCreator()

            logsViewController.sseService = sseService

            logsViewController.logsStylingParser = LogsStylingParser()
            logsViewController.build = build
            logsViewController.target = target
        }
    }

    @IBAction func onRetriggerButtonTapped() {
        guard let target = target else { return }
        guard let jobName = jobValueLabel?.text else { return }
        guard let pipelineName = pipelineValueLabel?.text else { return }

        triggerBuildService.triggerBuild(forTarget: target, forJob: jobName, inPipeline: pipelineName) { build, error in
            var alertTitle: String?
            var alertMessage: String?
            if let build = build {
                alertTitle = "Build Triggered"
                alertMessage = "Build #\(build.id) triggered for \(build.jobName)"
            } else {
                alertTitle = "Build Trigger Failed"
                alertMessage = error?.details
            }

            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
