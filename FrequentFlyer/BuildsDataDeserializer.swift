import Foundation

class BuildsDataDeserializer {
    func deserialize(buildsData: NSData) -> (builds: [Build]?, error: DeserializationError?) {
        var buildsJSONObject: AnyObject?
        do {
            buildsJSONObject = try NSJSONSerialization.JSONObjectWithData(buildsData, options: .AllowFragments)
        } catch { }
        
        guard let buildsJSON = buildsJSONObject as? Array<NSDictionary> else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat))
        }
        
        var builds = [Build]()
        for buildDictionary in buildsJSON {
            guard let buildId = buildDictionary["id"] as? Int else { continue }
            guard let buildJobName = buildDictionary["job_name"] as? String else { continue }
            guard let buildStatus = buildDictionary["status"] as? String else { continue }
            
            builds.append(Build(id: buildId, jobName: buildJobName, status: buildStatus))
        }
        
        return (builds, nil)
    }
}
