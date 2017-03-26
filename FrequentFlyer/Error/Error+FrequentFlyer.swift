import Foundation

protocol FFError: LocalizedError, CustomStringConvertible {
    var details: String { get }
}
