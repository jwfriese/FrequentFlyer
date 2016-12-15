import Foundation

class SSEEventParser {
    func parseConcourseEventFromSSEEvent(event: SSEEvent) -> (log: LogEvent?, error: FFError?) {
        let eventJSONData = event.data!.data(using: String.Encoding.utf8)
        var eventJSONAny: Any?
        do {
            eventJSONAny = try JSONSerialization.jsonObject(with: eventJSONData!, options: .allowFragments)
        } catch {
            return (nil, BasicError(details: "Could not parse event: Input SSEEvent data is not valid JSON"))
        }

        guard let eventJSON = eventJSONAny as? NSDictionary else {
            return (nil, BasicError(details: "Could not parse event: Input SSEEvent data is not valid JSON"))
        }

        guard let baseData = eventJSON["data"] as? NSDictionary else {
            return (nil, BasicError(details: "Could read JSON data: Top-level 'data' field missing"))
        }

        guard let eventData = eventJSON["event"] as? String else {
            return (nil, BasicError(details: "Could read JSON data: 'event' descriptor field missing"))
        }

        if eventData != "log" {
            return (nil, BasicError(details: "Unsupported event type: '\(eventData)'"))
        }

        guard let payloadData = baseData["payload"] as? String else {
            return (nil, BasicError(details: "Invalid log event JSON: Missing 'payload' data"))
        }

        return (LogEvent(payload: payloadData), nil)
    }
}
