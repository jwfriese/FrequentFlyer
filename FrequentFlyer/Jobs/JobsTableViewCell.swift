import UIKit

class JobsTableViewCell: UITableViewCell {
    @IBOutlet weak var jobNameLabel: DarkInfoLabel?
    @IBOutlet weak var latestJobLastEventTimeLabel: UILabel?
    @IBOutlet weak var buildStatusBadge: BuildStatusBadge?

    override func awakeFromNib() {
        super.awakeFromNib()

        latestJobLastEventTimeLabel?.font = Style.Fonts.regular(withSize: 14)
        latestJobLastEventTimeLabel?.textColor = Style.Colors.veryLightInfoLabel
    }

    class var cellReuseIdentifier: String { get { return "Jobs Table View Cell" } }
}
