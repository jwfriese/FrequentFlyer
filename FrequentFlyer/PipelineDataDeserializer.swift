import Foundation

class PipelineDataDeserializer {
    func deserialize(data: NSData) -> (pipelines: [Pipeline]?, error: DeserializationError?) {
        var pipelinesJSONObject: AnyObject?
        do {
            pipelinesJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch { }

        guard let pipelinesJSON = pipelinesJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat))
        }

        var pipelines = [Pipeline]()
        for pipelineDictionary in pipelinesJSON {
            guard let pipelineName = pipelineDictionary["name"] as? String else { continue }
            pipelines.append(Pipeline(name: pipelineName))
        }

        return (pipelines, nil)
    }
}
