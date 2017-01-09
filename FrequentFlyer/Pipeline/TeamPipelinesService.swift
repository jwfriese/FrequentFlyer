import Foundation

class TeamPipelinesService {
    var httpClient = HTTPClient()
    var pipelineDataDeserializer = PipelineDataDeserializer()

    func getPipelines(forTarget target: Target, completion: (([Pipeline]?, FFError?) -> ())?) {
        guard let url = URL(string: target.api + "/api/v1/teams/" + target.teamName + "/pipelines") else {
            return
        }

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(target.token.value)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        httpClient.doRequest(request as URLRequest) { data, response, error in
            guard let completion = completion else {
                return
            }

            guard let data = data else {
                completion(nil, error)
                return
            }

            let deserializationResult = self.pipelineDataDeserializer.deserialize(data)
            completion(deserializationResult.pipelines, deserializationResult.error)
        }
    }
}
