import UIKit

class ConcourseEntryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var concourseURLEntryField: UITextField?
    @IBOutlet weak var submitButton: UIButton?

    var authMethodsService: AuthMethodsService?
    var unauthenticatedTokenService: UnauthenticatedTokenService?

    class var storyboardIdentifier: String { get { return "ConcourseEntry" } }
    class var showAuthMethodListSegueId: String { get { return "ShowAuthMethodList" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        concourseURLEntryField?.autocorrectionType = .No
        concourseURLEntryField?.keyboardType = .URL

        concourseURLEntryField?.delegate = self
        submitButton?.enabled = false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConcourseEntryViewController.showAuthMethodListSegueId {
            guard let authMethodListViewController = segue.destinationViewController as? AuthMethodListViewController else {
                return
            }

            guard let concourseURLString = concourseURLEntryField?.text else { return }
            guard let authMethodWrapper = sender as? ArrayWrapper<AuthMethod> else { return }

            authMethodListViewController.authMethods = authMethodWrapper.array
            authMethodListViewController.concourseURLString = concourseURLString
        }
        else if segue.identifier == ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let teamPipelinesViewController = segue.destinationViewController as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService
        }
    }

    @IBAction func submitButtonTapped() {
        guard let authMethodsService = authMethodsService else { return }
        guard let unauthenticatedTokenService = unauthenticatedTokenService else { return }
        guard let concourseURLString = concourseURLEntryField?.text else { return }

        authMethodsService.getMethods(forTeamName: "main", concourseURL: concourseURLString) { authMethods, error in
            if authMethods == nil || authMethods!.count == 0 {
                unauthenticatedTokenService.getUnauthenticatedToken(forTeamName: "main", concourseURL: concourseURLString) { token, error in
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

                    let newTarget = Target(name: "target",
                                           api: concourseURLString,
                                           teamName: "main",
                                           token: token)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier(ConcourseEntryViewController.setTeamPipelinesAsRootPageSegueId, sender: newTarget)
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let wrappedAuthMethods = ArrayWrapper<AuthMethod>(array: authMethods!)
                    self.performSegueWithIdentifier(ConcourseEntryViewController.showAuthMethodListSegueId, sender: wrappedAuthMethods)
                }
            }
        }
    }
}

extension ConcourseEntryViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        submitButton?.enabled = concourseURLEntryField?.text != ""
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        submitButton?.enabled = false
        return true
    }
}
