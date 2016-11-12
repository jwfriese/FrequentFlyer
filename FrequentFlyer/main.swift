import UIKit

let appDelegateName = Bundle.main.object(forInfoDictionaryKey: "App Delegate Name") as! String
let unsafePointerToArgv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
        to: UnsafeMutablePointer<Int8>.self,
        capacity: Int(CommandLine.argc)
)
UIApplicationMain(CommandLine.argc, unsafePointerToArgv, nil, appDelegateName)
