import Foundation
import RxSwift

class JobsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ data: Data) -> Observable<[Job]> {
        let jobsJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let jobsJSON = jobsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let jobs = jobsJSON.flatMap { jobsDictionary -> Job? in
            guard let name = jobsDictionary["name"] as? String else { return nil }
            guard let groups = jobsDictionary["groups"] as? Array<String> else { return nil }

            let finishedBuildJSON = jobsDictionary["finished_build"] as? NSDictionary
            let nextBuildJSON = jobsDictionary["next_build"] as? NSDictionary

            if finishedBuildJSON == nil && nextBuildJSON == nil { return nil }

            var finishedBuild: Build?
            if let finishedBuildJSON = finishedBuildJSON {
                let finishedBuildData = try? JSONSerialization.data(withJSONObject: finishedBuildJSON, options: .prettyPrinted)
                finishedBuild = finishedBuildData.flatMap { buildDataDeserializer.deserialize($0).value }
            }

            var nextBuild: Build?
            if let nextBuildJSON = nextBuildJSON {
                let nextBuildData = try? JSONSerialization.data(withJSONObject: nextBuildJSON, options: .prettyPrinted)
                nextBuild = nextBuildData.flatMap { buildDataDeserializer.deserialize($0).value }
            }

            return Job(name: name, nextBuild: nextBuild, finishedBuild: finishedBuild, groups: groups)
        }

        return Observable.from(optional: jobs)
    }
}
