import Foundation

class BasicAuthTokenService {
    var httpClient = HTTPClient()
    var tokenDataDeserializer = TokenDataDeserializer()

    func getToken(forTeamWithName teamName: String, concourseURL: String,
                                  username: String, password: String, completion: ((Token?, FFError?) -> ())?) {
        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let usernamePasswordData = "\(username):\(password)".data(using: String.Encoding.utf8)
        let base64EncodedAuthenticationDetails = usernamePasswordData!.base64EncodedString(options: NSData.Base64EncodingOptions())

        request.addValue("Basic \(base64EncodedAuthenticationDetails)", forHTTPHeaderField: "Authorization")

        httpClient.doRequest(request as URLRequest) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let deserializationResult = self.tokenDataDeserializer.deserialize(data)
            completion(deserializationResult.token, deserializationResult.error)
        }
    }
}
