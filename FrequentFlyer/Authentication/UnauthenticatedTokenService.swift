import Foundation

class UnauthenticatedTokenService {
    var httpClient = HTTPClient()
    var tokenDataDeserializer = TokenDataDeserializer()

    func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, FFError?) -> ())?) {
        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        httpClient.doRequest(request as URLRequest) { response, error in
            guard let completion = completion else { return }
            guard let data = response?.body else {
                completion(nil, error)
                return
            }

            let deserializationResult = self.tokenDataDeserializer.deserializeold(data)
            completion(deserializationResult.token, deserializationResult.error)
        }
    }
}
