import UIKit

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}

class RoundedButton: UIButton {
    func setUp(withTitleText titleText: String,
               titleFont: UIFont,
               controlStateTitleColors titleColors: [UIControlState : UIColor],
               controlStateButtonColors buttonColors: [UIControlState : UIColor]) {
        for (state) in UIButton.allControlStates {
            setTitle(titleText, for: state)
        }
        titleLabel?.textAlignment = .center
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
