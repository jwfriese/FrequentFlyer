import UIKit

class ControlPanel: UIView {
    fileprivate struct IBTags {
        fileprivate static let latestJobNameLabelTag = 1
        fileprivate static let latestJobStatusLabelTag = 2
    }

    private var contentView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let viewPackage = Bundle.main.loadNibNamed("ControlPanel", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'ControlPanel'")
            return
        }

        contentView = loadedView
        addSubview(contentView)
        contentView.bounds = bounds
        autoresizesSubviews = true
        autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        latestJobNameLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobNameLabel?.textColor = Style.Colors.darkInfoLabel

        latestJobStatusLabel?.font = Style.Fonts.regular(withSize: 22)
        latestJobStatusLabel?.textColor = Style.Colors.darkInfoLabel
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

    private weak var cachedLatestJobNameLabel: UILabel?
    weak var latestJobNameLabel: UILabel? {
        get {
            if cachedLatestJobNameLabel != nil { return cachedLatestJobNameLabel }

            let label = contentView.subviews.filter { subview in
                return subview.tag == ControlPanel.IBTags.latestJobNameLabelTag
                }.first as? UILabel

            cachedLatestJobNameLabel = label
            return cachedLatestJobNameLabel
        }
    }

    private weak var cachedLatestJobStatusLabel: UILabel?
    weak var latestJobStatusLabel: UILabel? {
        get {
            if cachedLatestJobStatusLabel != nil { return cachedLatestJobStatusLabel }

            let label = contentView.subviews.filter { subview in
                return subview.tag == ControlPanel.IBTags.latestJobStatusLabelTag
                }.first as? UILabel

            cachedLatestJobStatusLabel = label
            return cachedLatestJobStatusLabel
        }
    }
}
