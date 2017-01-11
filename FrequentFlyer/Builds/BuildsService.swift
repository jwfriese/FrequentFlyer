import Foundation

class BuildsService {
    var httpClient = HTTPClient()
    var buildsDataDeserializer = BuildsDataDeserializer()

    func getBuilds(forTarget target: Target, completion: (([Build]?, FFError?) -> ())?) {
        let urlString = "\(target.api)/api/v1/builds"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(target.token.authValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        httpClient.doRequest(request) { response, error in
            guard let completion = completion else { return }
            guard let data = response?.body else {
                completion(nil, error)
                return
            }

            let result = self.buildsDataDeserializer.deserialize(data)
            completion(result.builds, result.error)
        }
    }
}
