import Foundation
import RxSwift
import ObjectMapper

class PipelineDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[Pipeline]> {
        var pipelinesJSONObject: Any?
        do {
            pipelinesJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let pipelinesCollection = pipelinesJSONObject as? Array<NSDictionary> else {
            return Observable.error(
                MapError(key: "", currentValue: "", reason: "Could not interpret data as JSON")
            )
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

        return Observable.just(pipelines)
    }
}
