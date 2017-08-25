import Crashlytics

class Logger {
    func logError(_ error: Error) {
        Crashlytics.sharedInstance().recordError(error)
    }
}
