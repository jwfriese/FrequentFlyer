import Foundation

class BuildsDataDeserializer {
    func deserialize(_ buildsData: Data) -> (builds: [Build]?, error: DeserializationError?) {
        var buildsJSONObject: Any?
        do {
            buildsJSONObject = try JSONSerialization.jsonObject(with: buildsData, options: .allowFragments)
        } catch { }

        guard let buildsJSON = buildsJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        var builds = [Build]()
        for buildDictionary in buildsJSON {
            guard let id = buildDictionary["id"] as? Int else { continue }
            guard let jobName = buildDictionary["job_name"] as? String else { continue }
            guard let status = buildDictionary["status"] as? String else { continue }
            guard let pipelineName = buildDictionary["pipeline_name"] as? String else { continue }

            builds.append(Build(id: id, jobName: jobName, status: status, pipelineName: pipelineName))
        }

        return (builds, nil)
    }
}
