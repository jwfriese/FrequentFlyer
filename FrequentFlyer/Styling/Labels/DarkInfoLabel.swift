import UIKit

class DarkInfoLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.regular(withSize: 18)
        textColor = Style.Colors.darkInfoLabel
    }
}
