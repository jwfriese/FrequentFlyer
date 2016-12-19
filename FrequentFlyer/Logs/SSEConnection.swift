import EventSource

class SSEConnection {
    private var eventSource: EventSource!
    private var sseEventParser: SSEEventParser!

    var onLogsReceived: (([LogEvent]) -> ())?

    var urlString: String {
        get {
            return eventSource.url.absoluteString
        }
    }

    init(eventSource: EventSource, sseEventParser: SSEEventParser) {
        self.eventSource = eventSource
        self.sseEventParser = sseEventParser

        self.eventSource.onMessagesReceived(onMessagesReceived)
    }

    fileprivate var onMessagesReceived: (([SSEEvent]) -> ()) {
        get {
            return { events in
                var logs = [LogEvent]()

                for event in events {
                    let (log, error) = self.sseEventParser.parseConcourseEventFromSSEEvent(event: event)
                    if let log = log {
                        logs.append(log)
                    } else if let error = error {
                        print(error.details)
                    }
                }

                if let onLogsReceived = self.onLogsReceived {
                    onLogsReceived(logs)
                }
            }
        }
    }
}
