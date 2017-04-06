import UIKit

class BuildStatusBadge: UIView {
    private var contentView: UIView!
    var status: BuildStatus?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let viewPackage = Bundle.main.loadNibNamed("BuildStatusBadge", owner: self, options: nil)
        guard let loadedView = viewPackage?.first as? UIView else {
            print("Failed to load nib with name 'BuildStatusBadge'")
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

    func setUp(for buildStatus: BuildStatus) {
        status = buildStatus

        var text = ""
        var badgeColor = UIColor.black

        switch buildStatus {
        case .pending:
            text = "Pending"
            badgeColor = Style.Colors.Status.pending
        case .started:
            text = "Started"
            badgeColor = Style.Colors.Status.started
        case .succeeded:
            text = "Succeeded"
            badgeColor = Style.Colors.Status.succeeded
        case .failed:
            text = "Failed"
            badgeColor = Style.Colors.Status.failed
        case .errored:
            text = "Errored"
            badgeColor = Style.Colors.Status.errored
        case .aborted:
            text = "Aborted"
            badgeColor = Style.Colors.Status.aborted
        case .paused:
            text = "Paused"
            badgeColor = Style.Colors.Status.paused
        }

        setUp(withText: text,
              font: Style.Fonts.bold(withSize: 12),
              textColor: UIColor.white,
              badgeColor: badgeColor
        )
    }

    private func setUp(withText text: String,
               font: UIFont,
               textColor: UIColor,
               badgeColor: UIColor) {
        textLabel?.textAlignment = .center
        textLabel?.font = font
        textLabel?.text = text
        textLabel?.textColor = textColor

        backgroundColor = badgeColor

        layer.cornerRadius = 2.0
        layer.masksToBounds = true
    }

    private weak var cachedTextLabel: UILabel?
    weak var textLabel: UILabel? {
        get {
            if cachedTextLabel != nil { return cachedTextLabel }

            let label = contentView.subviews.filter { subview in
                return subview.isKind(of: UILabel.self)
                }.first as? UILabel

            cachedTextLabel = label
            return cachedTextLabel
        }
    }
}
