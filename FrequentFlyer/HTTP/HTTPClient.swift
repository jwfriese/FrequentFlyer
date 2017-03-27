import Foundation
import RxSwift

class HTTPClient {
    let session: URLSession

    init() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: sessionConfig)
    }

    func perform(request: URLRequest) -> Observable<HTTPResponse> {
        let $ = PublishSubject<HTTPResponse>()

        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let response = response else {
                guard let error = error else {
                    $.onError(BasicError(details: "Unexpected error - received no response and no error"))
                    return
                }

                $.onError(BasicError(details: error.localizedDescription))
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                $.onError(BasicError(details: "HTTPClient only supports HTTP and HTTPS"))
                return
            }

            $.onNext(HTTPResponseImpl(body: data, statusCode: httpURLResponse.statusCode))
            $.onCompleted()
        })

        dataTask.resume()

        return $.asObservable()
    }
}
