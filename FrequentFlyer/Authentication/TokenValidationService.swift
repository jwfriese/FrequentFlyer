import Foundation

class TokenValidationService {
    var httpClient: HTTPClient?

    func validate(token token: Token, forConcourse concourseURLString: String, completion: ((Error?) -> ())?) {
        guard let completion = completion else { return }
        guard let httpClient = httpClient else { return }

        let urlString = "\(concourseURLString)/api/v1/containers"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)

        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")

        httpClient.doRequest(request) { _, response, error in
            if response?.statusCode == 401 {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
