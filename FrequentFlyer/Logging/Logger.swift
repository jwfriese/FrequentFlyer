import Crashlytics

class Logger {
    private init() {}

    static func logError(_ error: Error) {
        Crashlytics.sharedInstance().recordError(error)
    }
}
