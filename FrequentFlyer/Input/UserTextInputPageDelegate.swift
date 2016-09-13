import UIKit

protocol UserTextInputPageDelegate: class {
    var textFields: [UITextField] { get }
    var pageView: UIView { get }
    var pageScrollView: UIScrollView { get }
}
