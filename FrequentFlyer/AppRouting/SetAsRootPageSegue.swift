import UIKit

class SetAsRootPageSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }

    override func perform() {
        if let navigationController = sourceViewController.navigationController {
            navigationController.setViewControllers([destinationViewController], animated: true)
        } else {
            print("SetAsRootPageSegue requires that the source view controller is in a navigation controller")
        }
    }
}
