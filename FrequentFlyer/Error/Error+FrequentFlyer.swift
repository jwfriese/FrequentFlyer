import protocol Foundation.LocalizedError

protocol FFError: LocalizedError, CustomStringConvertible {
    var details: String { get }
}
