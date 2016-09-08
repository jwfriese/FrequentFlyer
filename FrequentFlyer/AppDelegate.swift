import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let targetListViewController = navigationController?.topViewController as? TargetListViewController
        targetListViewController?.targetListService = TargetListService()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

