import UIKit

class UnderlineTextFieldTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.titledTextFieldContent
        textColor = Style.Colors.titledTextFieldContentColor
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: font!.pointSize * 2)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let tolerance = CGFloat(10.0)
        if event?.type == .touches {
            let bottomBound = bounds.origin.y + bounds.size.height
            if point.y <= (bottomBound + tolerance) {
                return self
            }
        }

        return nil
    }
}
