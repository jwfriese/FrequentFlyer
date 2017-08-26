import Foundation
import class UIKit.UIApplication
import RxSwift
import RxCocoa

class HTTPClient {
    let session: URLSession

    init() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: sessionConfig)
    }

    func perform(request: URLRequest) -> Observable<HTTPResponse> {
        return session.rx.response(request: request)
            .do(onSubscribed: {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            })
            .map { response, data in
                return HTTPResponseImpl(body: data, statusCode: response.statusCode)
            }
            .do(onCompleted: {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
    }
}
