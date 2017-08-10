import UIKit
import Fabric
import Crashlytics

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        navigationController?.navigationBar.barTintColor = Style.Colors.navigationBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSAttributedStringKey.font : Style.Fonts.regular(withSize: 18)
        ]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        let appRouterViewController = navigationController?.topViewController as! AppRouterViewController
        appRouterViewController.keychainWrapper = KeychainWrapper()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

