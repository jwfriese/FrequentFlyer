import UIKit

class TeamTableViewCell: UITableViewCell {
    @IBOutlet weak var teamLabel: DarkInfoLabel?

    class var cellReuseIdentifier: String { get { return "TeamCell" } }
}
