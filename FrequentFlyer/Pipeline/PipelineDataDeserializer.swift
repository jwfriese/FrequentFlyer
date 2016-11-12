import Foundation

class PipelineDataDeserializer {
    func deserialize(_ data: Data) -> (pipelines: [Pipeline]?, error: DeserializationError?) {
        var pipelinesJSONObject: Any?
        do {
            pipelinesJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let pipelinesJSON = pipelinesJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        var pipelines = [Pipeline]()
        for pipelineDictionary in pipelinesJSON {
            guard let pipelineName = pipelineDictionary["name"] as? String else { continue }
            pipelines.append(Pipeline(name: pipelineName))
        }

        return (pipelines, nil)
    }
}
