import Foundation
import SwiftyJSON
import Result

class BuildsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ buildsData: Data) -> Result<[Build], DeserializationError> {
        let buildsJSONObject = JSON(data: buildsData)

        if buildsJSONObject.type == SwiftyJSON.Type.null {
            return Result.failure(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let builds = buildsJSONObject.arrayValue.flatMap { nextBuildJSON -> Build? in
            guard let nextBuildJSONData = try? nextBuildJSON.rawData(options: .prettyPrinted) else { return nil }

            return buildDataDeserializer.deserialize(nextBuildJSONData).value
        }

        return Result.success(builds)
    }
}
