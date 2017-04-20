import Foundation
import SwiftyJSON
import RxSwift

class BuildsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ buildsData: Data) -> ReplaySubject<[Build]> {
        let $ = ReplaySubject<[Build]>.createUnbounded()
        let buildsJSONObject = JSON(data: buildsData)

        if buildsJSONObject.type == SwiftyJSON.Type.null {
            $.onError(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
            return $
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
        

        $.onNext(builds)
        return $
    }
}
