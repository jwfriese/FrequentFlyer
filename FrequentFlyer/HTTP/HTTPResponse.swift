import Foundation

protocol HTTPResponse {
    var body: Data? { get }
    var statusCode: Int { get }
    var isSuccess: Bool { get }
}

struct HTTPResponseImpl: HTTPResponse {
    fileprivate(set) var body: Data?
    fileprivate(set) var statusCode: Int

    init(body: Data?, statusCode: Int) {
        self.body = body
        self.statusCode = statusCode
    }

    var isSuccess: Bool {
        get {
            return statusCode >= 200 && statusCode < 300
        }
    }
}

