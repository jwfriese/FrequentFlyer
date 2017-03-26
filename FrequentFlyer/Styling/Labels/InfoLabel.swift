import UIKit

class InfoLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.infoLabel
        textColor = Style.Colors.lightInfoLabel
    }
}
