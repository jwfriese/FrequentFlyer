import UIKit

class AppRouterViewController: UIViewController {
    var keychainWrapper = KeychainWrapper()

    class var storyboardIdentifier: String { get { return "AppRouter" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }
    class var setTeamPipelinesAsRootPageSegueId: String { get { return "SetTeamPipelinesAsRootPage" } }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppRouterViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destination as? ConcourseEntryViewController else {
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
            guard let teamPipelinesViewController = segue.destination as? TeamPipelinesViewController else {
                return
            }

            teamPipelinesViewController.target = target

            let teamPipelinesService = TeamPipelinesService()
            teamPipelinesService.httpClient = HTTPClient()
            teamPipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            teamPipelinesViewController.teamPipelinesService = teamPipelinesService

            teamPipelinesViewController.keychainWrapper = KeychainWrapper()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedTarget = keychainWrapper.retrieveTarget() {
            performSegue(withIdentifier: AppRouterViewController.setTeamPipelinesAsRootPageSegueId, sender: savedTarget)
        } else {
            performSegue(withIdentifier: AppRouterViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
        }
    }
}
