import Foundation

class SSEService {
    var eventSourceCreator = EventSourceCreator()

    func openSSEConnection(target: Target, build: Build) -> SSEConnection {
        let urlString = "\(target.api)/api/v1/builds/\(build.id)/events"
        let authorizationValue = "Bearer \(target.token.value)"
        let logsEventSource = eventSourceCreator.create(withURL: urlString, headers: ["Authorization" : authorizationValue])

        return SSEConnection(eventSource: logsEventSource, sseEventParser: SSEEventParser())
    }
}
