import UIKit

class PipelineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    
    class var cellReuseIdentifier: String { get { return "PipelineCell" } }
}