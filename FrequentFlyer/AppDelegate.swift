import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let concourseEntryViewController = navigationController?.topViewController as! ConcourseEntryViewController

        concourseEntryViewController.userTextInputPageOperator = UserTextInputPageOperator()

        let authMethodsService = AuthMethodsService()
        authMethodsService.httpClient = HTTPClient()
        authMethodsService.authMethodsDataDeserializer = AuthMethodDataDeserializer()
        concourseEntryViewController.authMethodsService = authMethodsService

        let unauthenticatedTokenService = UnauthenticatedTokenService()
        unauthenticatedTokenService.httpClient = HTTPClient()
        unauthenticatedTokenService.tokenDataDeserializer = TokenDataDeserializer()
        concourseEntryViewController.unauthenticatedTokenService = unauthenticatedTokenService

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

