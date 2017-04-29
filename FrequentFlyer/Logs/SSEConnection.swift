import EventSource

class SSEConnection {
    private var eventSource: EventSource!
    private var sseEventParser: SSEMessageEventParser!

    var onLogsReceived: (([LogEvent]) -> ())?
    var onError: ((NSError) -> ())?

    var urlString: String {
        get {
            return eventSource.url.absoluteString
        }
    }

    init(eventSource: EventSource, sseEventParser: SSEMessageEventParser) {
        self.eventSource = eventSource
        self.sseEventParser = sseEventParser

        self.eventSource.onEventDispatched(onEventDispatched)
        self.eventSource.onError(onConnectionError)
    }

    fileprivate var onEventDispatched: ((SSEMessageEvent) -> ()) {
        get {
            return { event in
                var logs = [LogEvent]()

                let (log, error) = self.sseEventParser.parseConcourseEventFromSSEMessageEvent(event: event)
                if let log = log {
                    logs.append(log)
                } else if let error = error {
                    print(error.details)
                }

                if let onLogsReceived = self.onLogsReceived {
                    onLogsReceived(logs)
                }
            }
        }
    }

    fileprivate var onConnectionError: ((NSError?) -> ()) {
        get {
            return { error in
                guard let unboxedError = error else {
                    print("\(SSEConnection.self) error: Connection closed by \(EventSource.self) with nil error")
                    return
                }

                if let onError = self.onError {
                    onError(unboxedError)
                }
            }
        }
    }
}
