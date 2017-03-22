import UIKit

class Style {
    class Colors {
        static var backgroundColor = UIColor(colorLiteralRed: 245/255, green: 246/255, blue: 247/255, alpha: 1)
        static var pageTitleLabelColor = UIColor(colorLiteralRed: 52/255, green: 73/255, blue: 94/255, alpha: 1)
        static var titledTextFieldUnderlineColor = Style.Colors.pageTitleLabelColor
        static var titledTextFieldTitleLabelColor = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var titledTextFieldContentColor = UIColor(colorLiteralRed: 92/255, green: 109/255, blue: 127/255, alpha: 1)
        static var buttonNormal = UIColor(colorLiteralRed: 77/255, green: 169/255, blue: 225/255, alpha: 1)
    }

    class Fonts {
        static var pageTitle: UIFont {
            get {
                let attributes = [
                    UIFontDescriptorFamilyAttribute: "Lato",
                    UIFontDescriptorNameAttribute: "Lato-Bold"
                ]

                return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 22)
            }
        }

        static var titledTextFieldTitle: UIFont {
            get {
                let attributes = [
                    UIFontDescriptorFamilyAttribute: "Lato",
                    UIFontDescriptorNameAttribute: "Lato-Bold"
                ]

                return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 16)
            }
        }

        static var titledTextFieldContent: UIFont {
            get {
                let attributes = [
                    UIFontDescriptorFamilyAttribute: "Lato",
                    UIFontDescriptorNameAttribute: "Lato-Regular"
                ]

                return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 18)
            }
        }

        static var button: UIFont = Style.Fonts.titledTextFieldTitle
    }
}
