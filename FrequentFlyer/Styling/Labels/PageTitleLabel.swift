import UIKit

class PageTitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.pageTitle
        textColor = Style.Colors.pageTitleLabelColor
    }
}
