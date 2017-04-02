import Foundation
import SwiftyJSON

class BuildsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ buildsData: Data) -> (builds: [Build]?, error: DeserializationError?) {
        let buildsJSONObject = JSON(data: buildsData)

        if buildsJSONObject.type == SwiftyJSON.Type.null {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        var builds = [Build]()
        for nextBuildJSON in buildsJSONObject.arrayValue {
            do {
                let nextBuildJSONData = try nextBuildJSON.rawData(options: .prettyPrinted)
                let deserializeResult = buildDataDeserializer.deserialize(nextBuildJSONData)
                if let build = deserializeResult.build {
                    builds.append(build)
                }
            } catch {}
        }

        return (builds, nil)
    }
}
