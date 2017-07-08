import protocol Foundation.LocalizedError
import Crashlytics

struct UnexpectedError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
        CLSLogv("%@", getVaList([message]))
    }

    var errorDescription: String? {
        get {
            return message
        }
    }

    var failureReason: String? {
        get {
            return message
        }
    }
}
