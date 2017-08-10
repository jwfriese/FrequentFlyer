import UIKit

class Style {
    class Colors {
        static var backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 247/255, alpha: 1)
        static var pageTitleLabelColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1)
        static var titledTextFieldUnderlineColor = Style.Colors.pageTitleLabelColor
        static var titledTextFieldTitleLabelColor = UIColor(red: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var titledTextFieldContentColor = UIColor(red: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var buttonNormal = UIColor(red: 77/255, green: 169/255, blue: 225/255, alpha: 1)
        static var veryLightInfoLabel = UIColor(red: 137/255, green: 157/255, blue: 178/255, alpha: 1)
        static var lightInfoLabel = UIColor(red: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var darkInfoLabel = UIColor(red: 25/255, green: 37/255, blue: 47/255, alpha: 1)
        static var navigationBar = UIColor(red: 77/255, green: 169/255, blue: 225/255, alpha: 1)
        static var logsBackground = UIColor(red: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var lightLoadingIndicator = UIColor.white

        class Status {
            static var pending = UIColor(red: 176/255, green: 181/255, blue: 185/255, alpha: 1)
            static var started = UIColor(red: 223/255, green: 181/255, blue: 14/255, alpha: 1)
            static var succeeded = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            static var failed = UIColor(red: 214/255, green: 70/255, blue: 56/255, alpha: 1)
            static var errored = UIColor(red: 214/255, green: 117/255, blue: 31/255, alpha: 1)
            static var aborted = UIColor(red: 139/255, green: 73/255, blue: 44/255, alpha: 1)
            static var paused = UIColor(red: 47/255, green: 138/255, blue: 199/255, alpha: 1)
        }
    }

    class Fonts {
        static func regular(withSize size: CGFloat) -> UIFont {
            let attributes = [
                UIFontDescriptor.AttributeName.family: "Lato",
                UIFontDescriptor.AttributeName.name: "Lato-Regular"
            ]

            return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: size)
        }

        static func bold(withSize size: CGFloat) -> UIFont {
            let attributes = [
                UIFontDescriptor.AttributeName.family: "Lato",
                UIFontDescriptor.AttributeName.name: "Lato-Bold"
            ]

            return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: size)
        }

        static var pageTitle: UIFont = Style.Fonts.bold(withSize: 22)
        static var titledTextFieldTitle: UIFont = Style.Fonts.bold(withSize: 16)
        static var titledTextFieldContent: UIFont = Style.Fonts.regular(withSize: 18)

        static var button: UIFont = Style.Fonts.titledTextFieldTitle
        static var infoLabel: UIFont = Style.Fonts.titledTextFieldTitle
        static var tableViewCellPrimaryLabel: UIFont = Style.Fonts.titledTextFieldContent
    }
}
