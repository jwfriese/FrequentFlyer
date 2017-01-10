import Foundation

class AuthMethodsService {
    var httpClient = HTTPClient()
    var authMethodsDataDeserializer = AuthMethodDataDeserializer()

    func getMethods(forTeamName teamName: String, concourseURL: String, completion: (([AuthMethod]?, FFError?) -> ())?) {
        let urlString = "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods"
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

            let deserializationResult = self.authMethodsDataDeserializer.deserialize(data)
            completion(deserializationResult.authMethods, deserializationResult.error)
        }
    }
}
