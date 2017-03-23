import UIKit
import BEMCheckBox

class TitledCheckBox: UIView {
    private var contentView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let viewPackage = Bundle.main.loadNibNamed("TitledCheckBox", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'TitledCheckBox'")
            return
        }

        contentView = loadedView
        addSubview(contentView)
        contentView.bounds = bounds
        autoresizesSubviews = true
        autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

    private weak var cachedTitleLabel: TitledCheckBoxTitleLabel?
    weak var titleLabel: TitledCheckBoxTitleLabel? {
        get {
            if cachedTitleLabel != nil { return cachedTitleLabel }

            let label = contentView.subviews.filter { subview in
                return subview.isKind(of: TitledCheckBoxTitleLabel.self)
                }.first as? TitledCheckBoxTitleLabel

            cachedTitleLabel = label
            return cachedTitleLabel
        }
    }

    private weak var cachedCheckBox: BEMCheckBox?
    weak var checkBox: BEMCheckBox? {
        get {
            if cachedCheckBox != nil { return cachedCheckBox }

            let checkBox = contentView.subviews.filter { subview in
                return subview.isKind(of: BEMCheckBox.self)
                }.first as? BEMCheckBox

            cachedCheckBox = checkBox
            return cachedCheckBox
        }
    }
}
