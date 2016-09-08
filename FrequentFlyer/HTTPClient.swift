import Foundation

class HTTPClient {
    func doRequest(request: NSURLRequest, completion: ((NSData?, HTTPResponse?, Error?) -> ())?) {
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { data, response, error in
            guard let completion = completion else { return }
            guard let response = response else {
                guard let error = error else {
                    completion(nil, nil, BasicError(details: "Unexpected error - received no response and no error"))
                    return
                }
                
                completion(nil, nil, BasicError(details: error.localizedDescription))
                return
            }
            
            guard let httpURLResponse = response as? NSHTTPURLResponse else {
                completion(nil, nil, BasicError(details: "HTTPClient only supports HTTP and HTTPS"))
                return
            }
            
            let httpResponse = HTTPResponseImpl(statusCode: httpURLResponse.statusCode)
            
            if httpResponse.isSuccess {
                completion(data, httpResponse, nil)
            } else {
                let errorDetails = String(data: data!, encoding: NSUTF8StringEncoding)
                let error = BasicError(details: errorDetails!)
                completion(nil, httpResponse, error)
            }
        }
        
        dataTask.resume()
    }
}