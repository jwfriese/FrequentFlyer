import Foundation
import Result

class PipelineDataDeserializer {
    func deserialize(_ data: Data) -> Result<[Pipeline], DeserializationError> {
        let pipelinesJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let pipelinesJSONArray = pipelinesJSONObject as? Array<NSDictionary> else {
            return Result.failure(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let pipelines = pipelinesJSONArray.flatMap { pipelineDictionary -> Pipeline? in
            guard let pipelineName = pipelineDictionary["name"] as? String else { return nil }
            return Pipeline(name: pipelineName)
        }

        return Result.success(pipelines)
    }
}
