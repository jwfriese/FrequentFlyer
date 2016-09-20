import UIKit

class AppRouterViewController: UIViewController {
    var keychainWrapper: KeychainWrapper?

    class var storyboardIdentifier: String { get { return "AppRouter" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AppRouterViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destinationViewController as? ConcourseEntryViewController else {
                return
            }

            concourseEntryViewController.userTextInputPageOperator = UserTextInputPageOperator()

            let authMethodsService = AuthMethodsService()
            authMethodsService.httpClient = HTTPClient()
            authMethodsService.authMethodsDataDeserializer = AuthMethodDataDeserializer()
            concourseEntryViewController.authMethodsService = authMethodsService

            let unauthenticatedTokenService = UnauthenticatedTokenService()
            unauthenticatedTokenService.httpClient = HTTPClient()
            unauthenticatedTokenService.tokenDataDeserializer = TokenDataDeserializer()
            concourseEntryViewController.unauthenticatedTokenService = unauthenticatedTokenService

            concourseEntryViewController.navigationItem.hidesBackButton = true
        } else if segue.identifier == AppRouterViewController.setTeamPipelinesAsRootPageSegueId {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let keychainWrapper = keychainWrapper else { return }

        if let savedTarget = keychainWrapper.retrieveTarget() {
            performSegueWithIdentifier(AppRouterViewController.setTeamPipelinesAsRootPageSegueId, sender: savedTarget)
        } else {
            performSegueWithIdentifier(AppRouterViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
        }
    }
}
