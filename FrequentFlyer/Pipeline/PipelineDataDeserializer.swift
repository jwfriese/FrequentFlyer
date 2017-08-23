import Foundation
import Result
import ObjectMapper

class PipelineDataDeserializer {
    func deserialize(_ data: Data) -> Result<[Pipeline], AnyError> {
        var pipelinesJSONObject: Any?
        do {
            pipelinesJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let pipelinesCollection = pipelinesJSONObject as? Array<NSDictionary> else {
            let error = MapError(key: "", currentValue: "", reason: "Could not interpret data as JSON")
            return Result(error: AnyError(error))
        }

        var pipelines: [Pipeline] = []
        for pipelineDictionary in pipelinesCollection {
            var pipeline: Pipeline
            do {
                try pipeline = Pipeline(JSONObject: pipelineDictionary)
            } catch {
                continue
            }
            pipelines.append(pipeline)
        }

        return Result.success(pipelines)
    }
}
