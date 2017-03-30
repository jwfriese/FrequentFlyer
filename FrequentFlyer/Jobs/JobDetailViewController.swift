import UIKit

class JobDetailViewController: UIViewController {
    @IBOutlet weak var controlPanel: ControlPanel?
    @IBOutlet weak var retriggerButton: RoundedButton?

    var triggerBuildService = TriggerBuildService()

    var job: Job?

    class var storyboardIdentifier: String { get { return "JobDetail" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controlPanel = controlPanel else { return }
        guard let job = job else { return }
        guard let latestBuild = job.builds.first else { return }

        title = job.name
        controlPanel.backgroundColor = Style.Colors.backgroundColor


        controlPanel.latestJobNameLabel?.text = latestBuild.name
        controlPanel.latestJobStatusLabel?.text = latestBuild.status
    }
}
