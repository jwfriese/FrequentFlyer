import Foundation
import class UIKit.UIApplication
import RxSwift

class HTTPClient {
    let session: URLSession

    init() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: sessionConfig)
    }

    func perform(request: URLRequest) -> Observable<HTTPResponse> {
        let responseSubject = PublishSubject<HTTPResponse>()

        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let response = response else {
                guard let error = error else {
                    responseSubject.onError(BasicError(details: "Unexpected error - received no response and no error"))
                    return
                }

                responseSubject.onError(BasicError(details: error.localizedDescription))
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                responseSubject.onError(BasicError(details: "HTTPClient only supports HTTP and HTTPS"))
                return
            }

            responseSubject.onNext(HTTPResponseImpl(body: data, statusCode: httpURLResponse.statusCode))
            responseSubject.onCompleted()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })

        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        return responseSubject.asObservable()
    }
}
