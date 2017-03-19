import UIKit

class TitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.title
    }
}

extension TitleLabel: Styleable {
    static func apply() {}
}
