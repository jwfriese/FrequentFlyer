import Foundation

class TokenValidationService {
    var httpClient = HTTPClient()

    func validate(token: Token, forConcourse concourseURLString: String, completion: ((FFError?) -> ())?) {
        guard let completion = completion else { return }

        let urlString = "\(concourseURLString)/api/v1/containers"
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")

        httpClient.doRequest(request as URLRequest) { _, response, error in
            if response?.statusCode == 401 {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
