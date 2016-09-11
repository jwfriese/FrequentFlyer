import UIKit

class BuildDetailViewController: UIViewController {
    @IBOutlet weak var pipelineValueLabel: UILabel?
    @IBOutlet weak var jobValueLabel: UILabel?
    @IBOutlet weak var statusValueLabel: UILabel?

    var build: Build?

    class var storyboardIdentifier: String { get { return "BuildDetail" } }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let build = build else { return }

        title = "Build #\(build.id)"
        pipelineValueLabel?.text = build.pipelineName
        jobValueLabel?.text = build.jobName
        statusValueLabel?.text = build.status
    }
}
