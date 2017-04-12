import UIKit

class JobGroupHeaderView: UITableViewHeaderFooterView {
    private var containerView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let viewPackage = Bundle.main.loadNibNamed("JobGroupHeaderView", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'JobGroupHeaderView'")
            return
        }

        containerView = loadedView
        addSubview(containerView)
        containerView.bounds = bounds
        autoresizesSubviews = true
        autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.clear
    }

    private weak var cachedNameLabel: UILabel?
    weak var nameLabel: UILabel? {
        get {
            if cachedNameLabel != nil { return cachedNameLabel }

            let nameLabel = containerView.subviews.filter { subview in
                return subview.isKind(of: UILabel.self)
                }.first as? UILabel

            cachedNameLabel = nameLabel
            return cachedNameLabel
        }
    }
}
