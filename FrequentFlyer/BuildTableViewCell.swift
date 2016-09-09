import UIKit

class BuildTableViewCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel?
    @IBOutlet weak var jobNameLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?

    class var cellReuseIdentifier: String { get { return "BuildCell" } }
}
