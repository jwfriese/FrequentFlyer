import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class UserTextInputPageOperatorSpec: QuickSpec {
    override func spec() {
        class ActiveUITextField: UITextField {
            override init(frame: CGRect) {
                super.init(frame: frame)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            private override func isFirstResponder() -> Bool {
                return true
            }
        }

        class MockUserTextInputPageDelegate: UserTextInputPageDelegate {
            let inactiveView = UITextField(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
            let activeView = ActiveUITextField(frame: CGRect(x: 100, y: 300, width: 200, height: 40))
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
            let scrollView = UIScrollView()

            private var textFields: [UITextField] {
                get {
                    return [inactiveView, activeView]
                }
            }

            private var pageView: UIView {
                get {
                    return view
                }
            }

            private var pageScrollView: UIScrollView {
                get {
                    return scrollView
                }
            }
        }

        describe("UserTextInputPageOperator") {
            var subject: UserTextInputPageOperator!

            beforeEach {
                subject = UserTextInputPageOperator()
            }

            describe("Registering without a delegate set") {
                it("throws an error when UserTextInputPageOperator.keyboardDidShow is called") {
                    expect { try subject.keyboardDidShow(NSNotification(name: "", object: nil)) }.to(throwError() { error in
                        guard let basicError = error as? BasicError else {
                            fail("Failed to throw BasicError")
                            return
                        }

                        expect(basicError.details).to(equal("UserTextInputPageOperator requires a UserTextInputPageDelegate to function"))
                    })
                }

                it("throws an error when UserTextInputPageOperator.keyboardWillHide is called") {
                    expect { try subject.keyboardWillHide(NSNotification(name: "", object: nil)) }.to(throwError() { error in
                        guard let basicError = error as? BasicError else {
                            fail("Failed to throw BasicError")
                            return
                        }

                        expect(basicError.details).to(equal("UserTextInputPageOperator requires a UserTextInputPageDelegate to function"))
                        })
                }
            }

            describe("After setting a delegate") {
                var delegate: MockUserTextInputPageDelegate!

                beforeEach {
                    delegate = MockUserTextInputPageDelegate()

                    subject.delegate = delegate
                }

                describe("When the keyboard appears") {
                    beforeEach {
                        let keyboardFrameRect = CGRect(x: 0, y: 0, width: 100, height: 200)
                        let keyboardAppearsNotification = NSNotification(name: UIKeyboardDidShowNotification, object: nil, userInfo: [
                            UIKeyboardFrameBeginUserInfoKey : NSValue(CGRect: keyboardFrameRect)
                            ])

                        NSNotificationCenter.defaultCenter().postNotification(keyboardAppearsNotification)
                    }

                    it("adjusts the delegate scroll view's content insets") {
                        expect(delegate.scrollView.contentInset).to(equal(UIEdgeInsetsMake(0, 0, 200, 0)))
                        expect(delegate.scrollView.scrollIndicatorInsets).to(equal(UIEdgeInsetsMake(0, 0, 200, 0)))
                    }

                    describe("When the keyboard disappears") {
                        beforeEach {
                            let keyboardHideNotification = NSNotification(name: UIKeyboardWillHideNotification, object: nil)
                            NSNotificationCenter.defaultCenter().postNotification(keyboardHideNotification)
                        }

                        it("adjusts the delegate scroll view's content insets") {
                            expect(delegate.scrollView.contentInset).to(equal(UIEdgeInsetsZero))
                            expect(delegate.scrollView.scrollIndicatorInsets).to(equal(UIEdgeInsetsZero))
                        }
                    }
                }
            }
        }
    }
}
