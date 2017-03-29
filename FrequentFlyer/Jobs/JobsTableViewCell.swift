import UIKit

class JobsTableViewCell: UITableViewCell {
    @IBOutlet weak var jobNameLabel: DarkInfoLabel?

    class var cellReuseIdentifier: String { get { return "Jobs Table View Cell" } }
}
