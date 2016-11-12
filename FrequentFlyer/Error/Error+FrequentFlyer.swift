protocol FFError: Error, CustomStringConvertible {
    var details: String { get }
}
