import UIKit

class TitledTextFieldTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        font = Style.Fonts.titledTextFieldContent
        textColor = Style.Colors.titledTextFieldContentColor
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: font!.pointSize * 2)
        drawBorder()
    }

    func drawBorder() {
        let border = CALayer()
        let borderThickness = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: intrinsicContentSize.height - borderThickness, width:  frame.size.width, height: intrinsicContentSize.height)

        border.borderWidth = borderThickness
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
