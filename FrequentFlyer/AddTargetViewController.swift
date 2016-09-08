import UIKit

class AddTargetViewController: UIViewController {
    @IBOutlet weak var targetNameTextField: UITextField?
    @IBOutlet weak var concourseURLTextField: UITextField?
    @IBOutlet weak var addTargetButton: UIButton?
    
    weak var addTargetDelegate: AddTargetDelegate?
    var tokenAuthService: TokenAuthService?
    
    class var storyboardIdentifier: String {
        get {
            return "AddTarget"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Target"
        
        targetNameTextField?.delegate = self
        concourseURLTextField?.delegate = self
        
        addTargetButton?.enabled = false
    }
    
    @IBAction func onAddTargetTapped() {
        tokenAuthService?.getToken(forTeamName: "main", concourseURL: concourseURLTextField!.text!) { token, error in
            guard let token = token else {
                let alert = UIAlertController(title: "Authorization Failed",
                                              message: error?.details,
                                              preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            let newTarget = Target(name: self.targetNameTextField!.text!,
                                   api: self.concourseURLTextField!.text!,
                                   teamName: "main",
                                   token: token)
            self.addTargetDelegate?.onTargetAdded(newTarget)
        }
    }
}

extension AddTargetViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === targetNameTextField {
            if string != "" {
                addTargetButton?.enabled = concourseURLTextField?.text != ""
            } else {
                addTargetButton?.enabled = false
            }
        } else if textField === concourseURLTextField {
            if string != "" {
                addTargetButton?.enabled = targetNameTextField?.text != ""
            } else {
                addTargetButton?.enabled = false
            }
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        addTargetButton?.enabled = false
        return true
    }
}
