import UIKit

class TargetListTableViewCell: UITableViewCell {
    class var cellReuseIdentifier: String {
        get {
            return "TargetListCell"
        }
    }
    
    @IBOutlet weak var targetNameLabel: UILabel?
}