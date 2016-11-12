import UIKit

class UserTextInputPageOperator {
    weak var delegate: UserTextInputPageDelegate? {
        didSet {
            if delegate != nil {
                registerKeyboardNotifications()
            } else {
                unregisterKeyboardNotifications()
            }
        }
    }

    fileprivate var activeTextField: UITextField? {
        get {
            if let delegate = delegate {
                for textField in delegate.textFields {
                    if textField.isFirstResponder {
                        return textField
                    }
                }
            }

            return nil
        }
    }

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(UserTextInputPageOperator.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserTextInputPageOperator.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidShow(_ notification: Notification) throws {
        guard let delegate = delegate else {
            throw BasicError(details: "UserTextInputPageOperator requires a UserTextInputPageDelegate to function")
        }

        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        delegate.pageScrollView.contentInset = contentInsets
        delegate.pageScrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(_ notification: Notification) throws {
        guard let delegate = delegate else {
            throw BasicError(details: "UserTextInputPageOperator requires a UserTextInputPageDelegate to function")
        }

        delegate.pageScrollView.contentInset = UIEdgeInsets.zero
        delegate.pageScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
