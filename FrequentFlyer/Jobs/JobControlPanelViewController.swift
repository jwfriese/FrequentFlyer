import UIKit

class JobControlPanelViewController: UIViewController {
    @IBOutlet weak var latestJobNameLabel: UILabel?
    @IBOutlet weak var latestJobLastEventTimeLabel: UILabel?
    @IBOutlet weak var buildStatusBadge: BuildStatusBadge?
    @IBOutlet weak var retriggerButton: RoundedButton?

    var triggerBuildService = TriggerBuildService()
    var elapsedTimePrinter = ElapsedTimePrinter()

    var target: Target?
    var pipeline: Pipeline?
    private(set) var job: Job?

    class var storyboardIdentifier: String { get { return "JobControlPanel" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.Colors.backgroundColor

        latestJobNameLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobNameLabel?.textColor = Style.Colors.darkInfoLabel

        latestJobLastEventTimeLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobLastEventTimeLabel?.textColor = Style.Colors.darkInfoLabel

        retriggerButton?.setUp(withTitleText: "Retrigger",
                               titleFont: Style.Fonts.button,
                               controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                               controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )
    }

    func setJob(_ job: Job) {
        self.job = job
        guard let latestCompletedBuild = job.builds.first else { return }
        latestJobNameLabel?.text = latestCompletedBuild.name

        let timeSinceBuildEnded = TimeInterval(latestCompletedBuild.endTime)
        latestJobLastEventTimeLabel?.text = elapsedTimePrinter.printTime(since: timeSinceBuildEnded)

        buildStatusBadge?.setUp(for: latestCompletedBuild.status)
    }

    @IBAction func onRetriggerButtonTapped() {
        guard let target = target else { return }
        guard let job = job else { return }
        guard let pipeline = pipeline else { return }

        triggerBuildService.triggerBuild(forTarget: target, forJob: job.name, inPipeline: pipeline.name) { build, error in
            var alertTitle: String?
            var alertMessage: String?
            if let build = build {
                alertTitle = "Build Triggered"
                alertMessage = "Build #\(build.id) triggered for '\(build.jobName)'"
            } else {
                alertTitle = "Build Trigger Failed"
                alertMessage = error?.localizedDescription
            }

            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
