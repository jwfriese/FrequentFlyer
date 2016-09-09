import Foundation

class TeamPipelinesService {
    var httpClient: HTTPClient?
    var pipelineDataDeserializer: PipelineDataDeserializer?
    
    func getPipelines(forTarget target: Target, completion: (([Pipeline]?, Error?) -> ())?) {
        guard let httpClient = httpClient else { return }
        
        guard let url = NSURL(string: target.api + "/api/v1/teams/" + target.teamName + "/pipelines") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(target.token.value)", forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "GET"
        
        httpClient.doRequest(request) { data, response, error in
            guard let completion = completion else {
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let deserializationResult = self.pipelineDataDeserializer?.deserialize(data)
            completion(deserializationResult?.pipelines, deserializationResult?.error)
        }
    }
}