import UIKit

extension UIButton {
    class var allControlStates: [UIControlState] {
        return [
            .normal,
            .disabled,
            .selected,
            .highlighted,
            .focused,
            .application,
            .reserved
        ]
    }
}
