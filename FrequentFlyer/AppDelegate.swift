import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        let appRouterViewController = navigationController?.topViewController as! AppRouterViewController
        appRouterViewController.keychainWrapper = KeychainWrapper()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

