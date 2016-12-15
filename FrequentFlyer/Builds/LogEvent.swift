import Foundation

class LogEvent {
    fileprivate(set) var payload: String

    init(payload: String) {
        self.payload = payload
    }
}

extension LogEvent: Equatable {}

func ==(lhs: LogEvent, rhs: LogEvent) -> Bool {
    return lhs.payload == rhs.payload
}
