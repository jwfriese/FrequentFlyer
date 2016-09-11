import Foundation

class BasicAuthTokenService {
    var httpClient: HTTPClient?
    var tokenDataDeserializer: TokenDataDeserializer?

    func getToken(forTeamWithName teamName: String, concourseURL: String,
                                  username: String, password: String, completion: ((Token?, Error?) -> ())?) {
        guard let httpClient = httpClient else { return }
        guard let tokenDataDeserializer = tokenDataDeserializer else { return }

        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"

        let usernamePasswordData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedAuthenticationDetails = usernamePasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        request.addValue("Basic \(base64EncodedAuthenticationDetails)", forHTTPHeaderField: "Authorization")

        httpClient.doRequest(request) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let deserializationResult = tokenDataDeserializer.deserialize(data)
            completion(deserializationResult.token, deserializationResult.error)
        }
    }
}
