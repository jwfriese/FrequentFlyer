import Foundation

class PipelineDataDeserializer {
    func deserialize(_ data: Data) -> (pipelines: [Pipeline]?, error: DeserializationError?) {
        let pipelinesJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let pipelinesJSONArray = pipelinesJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let pipelines = pipelinesJSONArray.flatMap { pipelineDictionary -> Pipeline? in
            guard let pipelineName = pipelineDictionary["name"] as? String else { return nil }
            return Pipeline(name: pipelineName)
        }

        return (pipelines, nil)
    }
}
