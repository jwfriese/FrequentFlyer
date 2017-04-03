import UIKit

class Style {
    class Colors {
        static var backgroundColor = UIColor(colorLiteralRed: 245/255, green: 246/255, blue: 247/255, alpha: 1)
        static var pageTitleLabelColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1)
        static var titledTextFieldUnderlineColor = Style.Colors.pageTitleLabelColor
        static var titledTextFieldTitleLabelColor = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var titledTextFieldContentColor = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var buttonNormal = UIColor(colorLiteralRed: 77/255, green: 169/255, blue: 225/255, alpha: 1)
        static var lightInfoLabel = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var darkInfoLabel = UIColor(colorLiteralRed: 25/255, green: 37/255, blue: 47/255, alpha: 1)
        static var navigationBar = UIColor(colorLiteralRed: 77/255, green: 169/255, blue: 225/255, alpha: 1)
        static var logsBackground = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)

        class Status {
            static var pending = UIColor(colorLiteralRed: 176/255, green: 181/255, blue: 185/255, alpha: 1)
            static var started = UIColor(colorLiteralRed: 223/255, green: 181/255, blue: 14/255, alpha: 1)
            static var succeeded = UIColor(colorLiteralRed: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            static var failed = UIColor(colorLiteralRed: 214/255, green: 70/255, blue: 56/255, alpha: 1)
            static var errored = UIColor(colorLiteralRed: 214/255, green: 117/255, blue: 31/255, alpha: 1)
            static var aborted = UIColor(colorLiteralRed: 139/255, green: 73/255, blue: 44/255, alpha: 1)
            static var paused = UIColor(colorLiteralRed: 47/255, green: 138/255, blue: 199/255, alpha: 1)
        }
    }

    class Fonts {
        static func regular(withSize size: CGFloat) -> UIFont {
            let attributes = [
                UIFontDescriptorFamilyAttribute: "Lato",
                UIFontDescriptorNameAttribute: "Lato-Regular"
            ]

            return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: size)
        }

        static func bold(withSize size: CGFloat) -> UIFont {
            let attributes = [
                UIFontDescriptorFamilyAttribute: "Lato",
                UIFontDescriptorNameAttribute: "Lato-Bold"
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
