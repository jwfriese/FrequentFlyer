protocol Loggable {
    var loggingDescription: String { get }
}

extension String: Loggable {
    var loggingDescription: String { get { return self } }
}
