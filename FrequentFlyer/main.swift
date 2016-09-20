import UIKit

let appDelegateName = NSBundle.mainBundle().objectForInfoDictionaryKey("App Delegate Name") as! String
UIApplicationMain(Process.argc, Process.unsafeArgv, nil, appDelegateName)
