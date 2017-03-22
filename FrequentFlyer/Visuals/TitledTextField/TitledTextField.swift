import UIKit

class TitledTextField: UIView {
    private var contentView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let viewPackage = Bundle.main.loadNibNamed("TitledTextField", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'TitledTextField'")
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

    private weak var cachedTitleLabel: UILabel?
    weak var titleLabel: UILabel? {
        get {
            if cachedTitleLabel != nil { return cachedTitleLabel }

            let label = contentView.subviews.filter { subview in
                return subview.isKind(of: TitledTextFieldTitleLabel.self)
            }.first as? UILabel

            cachedTitleLabel = label
            return cachedTitleLabel
        }
    }

    private weak var cachedTextField: TitledTextFieldTextField?
    weak var textField: TitledTextFieldTextField? {
        get {
            if cachedTextField != nil { return cachedTextField }

            let textField = contentView.subviews.filter { subview in
                return subview.isKind(of: TitledTextFieldTextField.self)
                }.first as? TitledTextFieldTextField

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
