import UIKit

class TestAppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.window = UIWindow()
        self.window?.rootViewController = UIViewController()
        self.window!.makeKeyAndVisible()
        return true
    }
}
