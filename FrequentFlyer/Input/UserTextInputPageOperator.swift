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

    private var activeTextField: UITextField? {
        get {
            if let delegate = delegate {
                for textField in delegate.textFields {
                    if textField.isFirstResponder() {
                        return textField
                    }
                }
            }

            return nil
        }
    }

    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserTextInputPageOperator.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserTextInputPageOperator.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc func keyboardDidShow(notification: NSNotification) throws {
        guard let delegate = delegate else {
            throw BasicError(details: "UserTextInputPageOperator requires a UserTextInputPageDelegate to function")
        }

        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        delegate.pageScrollView.contentInset = contentInsets
        delegate.pageScrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) throws {
        guard let delegate = delegate else {
            throw BasicError(details: "UserTextInputPageOperator requires a UserTextInputPageDelegate to function")
        }

        delegate.pageScrollView.contentInset = UIEdgeInsetsZero
        delegate.pageScrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
