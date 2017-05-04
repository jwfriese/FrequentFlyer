import Foundation
import SwiftyJSON

class BuildsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ buildsData: Data) -> (builds: [Build]?, error: DeserializationError?) {
        let buildsJSONObject = JSON(data: buildsData)

        if buildsJSONObject.type == SwiftyJSON.Type.null {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let builds = buildsJSONObject.arrayValue.flatMap { nextBuildJSON -> Build? in
            guard let nextBuildJSONData = try? nextBuildJSON.rawData(options: .prettyPrinted) else { return nil }
            
            return buildDataDeserializer.deserialize(nextBuildJSONData).build
        }

        return (builds, nil)
    }
}
