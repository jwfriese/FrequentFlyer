import UIKit

class PageComponentTitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.titledTextFieldTitle
        textColor = Style.Colors.titledTextFieldTitleLabelColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        font = Style.Fonts.titledTextFieldTitle
        textColor = Style.Colors.titledTextFieldTitleLabelColor
    }
}
