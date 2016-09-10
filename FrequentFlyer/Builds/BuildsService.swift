import Foundation

class BuildsService {
    var httpClient: HTTPClient?
    var buildsDataDeserializer: BuildsDataDeserializer?

    func getBuilds(forTarget target: Target, completion: (([Build]?, Error?) -> ())?) {
        guard let httpClient = httpClient else { return }

        let urlString = "\(target.api)/api/v1/builds"
        guard let url = NSURL(string: urlString) else { return }

        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(target.token.value)", forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "GET"

        httpClient.doRequest(request) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let result = self.buildsDataDeserializer?.deserialize(data)
            completion(result?.builds, result?.error)
        }
    }
}
