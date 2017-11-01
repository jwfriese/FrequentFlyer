import UIKit

class AppRouterViewController: UIViewController {
    var keychainWrapper = KeychainWrapper()

    class var storyboardIdentifier: String { get { return "AppRouter" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }
    class var setPipelinesAsRootPageSegueId: String { get { return "SetPipelinesAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        let savedTarget = keychainWrapper.retrieveTarget()
        let isStayLoggedInActive = savedTarget != nil
        if isStayLoggedInActive {
            performSegue(withIdentifier: AppRouterViewController.setPipelinesAsRootPageSegueId, sender: savedTarget)
        } else {
            performSegue(withIdentifier: AppRouterViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppRouterViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destination as? ConcourseEntryViewController else {
                return
            }

            concourseEntryViewController.userTextInputPageOperator = UserTextInputPageOperator()
            concourseEntryViewController.navigationItem.hidesBackButton = true
        } else if segue.identifier == AppRouterViewController.setPipelinesAsRootPageSegueId {
            guard let target = sender as? Target else { return }
            guard let pipelinesViewController = segue.destination as? PipelinesViewController else {
                return
            }

            pipelinesViewController.target = target

            let pipelinesService = PipelinesService()
            pipelinesService.httpClient = HTTPClient()
            pipelinesService.pipelineDataDeserializer = PipelineDataDeserializer()
            pipelinesViewController.pipelinesService = pipelinesService

            pipelinesViewController.keychainWrapper = KeychainWrapper()
        }
    }
}
