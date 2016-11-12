import UIKit

class BuildDetailViewController: UIViewController {
    @IBOutlet weak var pipelineValueLabel: UILabel?
    @IBOutlet weak var jobValueLabel: UILabel?
    @IBOutlet weak var statusValueLabel: UILabel?
    @IBOutlet weak var retriggerButton: UIButton?

    var build: Build?
    var target: Target?
    var triggerBuildService: TriggerBuildService?

    class var storyboardIdentifier: String { get { return "BuildDetail" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let build = build else { return }

        title = "Build #\(build.id)"
        pipelineValueLabel?.text = build.pipelineName
        jobValueLabel?.text = build.jobName
        statusValueLabel?.text = build.status
    }

    @IBAction func onRetriggerButtonTapped() {
        guard let triggerBuildService = triggerBuildService else { return }
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
