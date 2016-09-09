import Foundation

class TokenAuthService {
    var httpClient: HTTPClient?
    var tokenDataDeserializer: TokenDataDeserializer?

    func getToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, Error?) -> ())?) {
        guard let httpClient = httpClient else { return }
        guard let tokenDataDeserializer = tokenDataDeserializer else { return }

        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"

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
