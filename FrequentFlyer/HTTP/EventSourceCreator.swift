import EventSource

class EventSourceCreator {
    func create(withURL url: String, headers: [String : String]) -> EventSource {
        return EventSource(url: url, headers: headers)
    }
}
