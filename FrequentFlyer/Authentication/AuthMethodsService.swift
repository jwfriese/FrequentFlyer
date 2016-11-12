import Foundation

class AuthMethodsService {
    var httpClient: HTTPClient?
    var authMethodsDataDeserializer: AuthMethodDataDeserializer?

    func getMethods(forTeamName teamName: String, concourseURL: String, completion: (([AuthMethod]?, FFError?) -> ())?) {
        guard let httpClient = httpClient else { return }
        guard let authMethodsDataDeserializer = authMethodsDataDeserializer else { return }

        let urlString = "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        httpClient.doRequest(request as URLRequest) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let deserializationResult = authMethodsDataDeserializer.deserialize(data)
            completion(deserializationResult.authMethods, deserializationResult.error)
        }
    }
}
