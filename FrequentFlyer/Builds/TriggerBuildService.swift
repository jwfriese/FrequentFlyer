import Foundation

class TriggerBuildService {
    var httpClient: HTTPClient?
    var buildDataDeserializer: BuildDataDeserializer?

    func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String, completion: ((Build?, FFError?) -> ())?) {
        guard let httpClient = httpClient else { return }
        guard let buildDataDeserializer = buildDataDeserializer else { return }

        let urlString = "\(target.api)/api/v1/teams/\(target.teamName)/pipelines/\(pipelineName)/jobs/\(jobName)/builds"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        request.allHTTPHeaderFields?["Authorization"] = "Bearer \(target.token.value)"

        httpClient.doRequest(request as URLRequest) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let deserializationResult = buildDataDeserializer.deserialize(data)
            completion(deserializationResult.build, deserializationResult.error)
        }
    }

}
