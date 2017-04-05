import UIKit

class BuildControlPanelViewController: UIViewController {
    @IBOutlet weak var timeHeaderLabel: UILabel?
    @IBOutlet weak var latestJobNameLabel: UILabel?
    @IBOutlet weak var latestJobLastEventTimeLabel: UILabel?
    @IBOutlet weak var buildStatusBadge: BuildStatusBadge?
    @IBOutlet weak var retriggerButton: RoundedButton?

    var triggerBuildService = TriggerBuildService()
    var elapsedTimePrinter = ElapsedTimePrinter()

    var target: Target?
    var pipeline: Pipeline?
    private(set) var build: Build?

    class var storyboardIdentifier: String { get { return "BuildControlPanel" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.Colors.backgroundColor

        latestJobNameLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobNameLabel?.textColor = Style.Colors.darkInfoLabel

        latestJobLastEventTimeLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobLastEventTimeLabel?.textColor = Style.Colors.darkInfoLabel

        timeHeaderLabel?.font = Style.Fonts.regular(withSize: 14)
        timeHeaderLabel?.textColor = Style.Colors.darkInfoLabel

        retriggerButton?.setUp(withTitleText: "Retrigger",
                               titleFont: Style.Fonts.button,
                               controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                               controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )
    }

    func setBuild(_ build: Build) {
        self.build = build
        latestJobNameLabel?.text = "#\(build.name)"
        buildStatusBadge?.setUp(for: build.status)

        if let endTime = build.endTime {
            let timeSinceBuildEnded = TimeInterval(endTime)
            latestJobLastEventTimeLabel?.text = elapsedTimePrinter.printTime(since: timeSinceBuildEnded)
            timeHeaderLabel?.text = "Finished"
        } else if let startTime = build.startTime {
            let timeSinceBuildStarted = TimeInterval(startTime)
            latestJobLastEventTimeLabel?.text = elapsedTimePrinter.printTime(since: timeSinceBuildStarted)
            timeHeaderLabel?.text = "Started"
        } else {
            latestJobLastEventTimeLabel?.text = "--"
            timeHeaderLabel?.text = ""
        }
    }

    @IBAction func onRetriggerButtonTapped() {
        guard let target = target else { return }
        guard let build = build else { return }
        guard let pipeline = pipeline else { return }

        triggerBuildService.triggerBuild(forTarget: target, forJob: build.jobName, inPipeline: pipeline.name) { build, error in
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
