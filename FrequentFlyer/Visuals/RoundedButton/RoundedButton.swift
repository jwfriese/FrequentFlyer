import UIKit

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}

class RoundedButton: UIButton {
    func initialize(withTitleText titleText: String,
                    titleFont: UIFont,
                    controlStateTitleColors titleColors: [UIControlState : UIColor],
                    controlStateButtonColors buttonColors: [UIControlState : UIColor]) {
        titleLabel?.text = titleText
        titleLabel?.font = titleFont
        for (state, color) in titleColors {
            setTitleColor(color, for: state)
        }

        for (state, color) in buttonColors {
            setBackgroundImage(UIImage.image(withFillColor: color), for: state)
        }

        layer.cornerRadius = 2.0
        layer.masksToBounds = true
    }
}
