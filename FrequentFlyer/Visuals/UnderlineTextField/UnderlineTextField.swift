import UIKit

class UnderlineTextField: UIView {
    private var contentView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let viewPackage = Bundle.main.loadNibNamed("UnderlineTextField", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'UnderlineTextField'")
            return
        }

        contentView = loadedView
        addSubview(contentView)
        contentView.bounds = bounds
        autoresizesSubviews = true
        autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        underline?.backgroundColor = Style.Colors.titledTextFieldUnderlineColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Because this view contains the actual text view, explicitly give it a chance
        // to claim a touch it otherwise wouldn't.
        if let hitTextField = textField?.hitTest(point, with: event) {
            return hitTextField
        }

        return super.hitTest(point, with: event)
    }

    private weak var cachedTextField: UnderlineTextFieldTextField?
    weak var textField: UnderlineTextFieldTextField? {
        get {
            if cachedTextField != nil { return cachedTextField }

            let textField = contentView.subviews.filter { subview in
                return subview.isKind(of: UnderlineTextFieldTextField.self)
                }.first as? UnderlineTextFieldTextField

            cachedTextField = textField
            return cachedTextField
        }
    }

    private weak var cachedUnderline: Underline?
    private weak var underline: Underline? {
        get {
            if cachedUnderline != nil { return cachedUnderline }

            let underline = contentView.subviews.filter { subview in
                return subview.isKind(of: Underline.self)
                }.first as? Underline

            cachedUnderline = underline
            return cachedUnderline
        }
    }
}
