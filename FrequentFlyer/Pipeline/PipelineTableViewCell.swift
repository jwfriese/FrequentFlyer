import UIKit

class PipelineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: DarkInfoLabel?

    class var cellReuseIdentifier: String { get { return "PipelineCell" } }
}
