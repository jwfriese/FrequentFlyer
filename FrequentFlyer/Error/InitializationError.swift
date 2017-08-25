typealias LoggableMap = [String : Loggable]

enum InitializationError: Error {
    case serviceURL(functionName: String, data: [String : Loggable])

    var description: String {
        get {
            switch (self) {
            case .serviceURL(let selector, let data):
                return "Failed to create URL for \(selector)\nExtra details: \(print(data))"
            }
        }
    }

    private func print(_ loggableMap: LoggableMap) -> String {
        var str = "["
        loggableMap.forEach { key, value in
            str += "\(key) : \(value.loggingDescription)"
        }

        return str.appending("]")
    }
}
