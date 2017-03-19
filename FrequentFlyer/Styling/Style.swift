import UIKit

class Style {
//    static var allStyleables: [Styleable] =

    class Colors {
        static var backgroundColor = UIColor(colorLiteralRed: 245/255, green: 246/255, blue: 247/255, alpha: 1)
    }

    class Fonts {
        static var title: UIFont {
            get {
                let attributes = [
                    UIFontDescriptorFamilyAttribute: "Lato",
                    UIFontDescriptorNameAttribute: "Lato-Bold"
                ]

                return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 22)
            }
        }
    }
}
