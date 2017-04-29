import EventSource

class SSEConnection {
    private var eventSource: EventSource!
    private var sseEventParser: SSEMessageEventParser!

    var onLogsReceived: (([LogEvent]) -> ())?

    var urlString: String {
        get {
            return eventSource.url.absoluteString
        }
    }

    init(eventSource: EventSource, sseEventParser: SSEMessageEventParser) {
        self.eventSource = eventSource
        self.sseEventParser = sseEventParser

        self.eventSource.onEventDispatched(onEventDispatched)
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
}
