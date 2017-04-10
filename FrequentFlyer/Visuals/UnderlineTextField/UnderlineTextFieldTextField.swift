import UIKit

class UnderlineTextFieldTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.titledTextFieldContent
        textColor = Style.Colors.titledTextFieldContentColor
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: font!.pointSize * 2)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let topTolerance = CGFloat(14.0)
        let bottomTolerance = CGFloat(10.0)
        if event?.type == .touches {
            let topBound = bounds.origin.y
            let bottomBound = bounds.origin.y + bounds.size.height
            let isWithinTopBound = point.y >= (topBound - topTolerance)
            let isWithinBottomBound = point.y <= (bottomBound + bottomTolerance)
            if isWithinTopBound && isWithinBottomBound {
                return self
            }
        }

        return nil
    }
}
