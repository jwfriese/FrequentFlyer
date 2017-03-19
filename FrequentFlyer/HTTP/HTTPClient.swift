import Foundation

class HTTPClient {
    let session: URLSession

    init() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: sessionConfig)
    }

    func doRequest(_ request: URLRequest, completion: ((HTTPResponse?, FFError?) -> ())?) {
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let completion = completion else { return }
            guard let response = response else {
                guard let error = error else {
                    completion(nil, BasicError(details: "Unexpected error - received no response and no error"))
                    return
                }

                completion(nil, BasicError(details: error.localizedDescription))
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                completion(nil, BasicError(details: "HTTPClient only supports HTTP and HTTPS"))
                return
            }

            let httpResponse = HTTPResponseImpl(body: data, statusCode: httpURLResponse.statusCode)
            completion(httpResponse, nil)
        })

        dataTask.resume()
    }
}
