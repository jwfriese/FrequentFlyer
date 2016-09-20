import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController

        let appRouterViewController = navigationController?.topViewController as! AppRouterViewController
        appRouterViewController.keychainWrapper = KeychainWrapper()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

