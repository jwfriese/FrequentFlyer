import Foundation
import RxSwift

class JobsDataDeserializer {
    var buildDataDeserializer = BuildDataDeserializer()

    func deserialize(_ data: Data) -> Observable<[Job]> {
        var jobsJSONObject: Any?
        do {
            jobsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        var jobs = [Job]()

        guard let jobsJSON = jobsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        for jobsDictionary in jobsJSON {
            guard let name = jobsDictionary["name"] as? String else { continue }

            let finishedBuildJSON = jobsDictionary["finished_build"] as? NSDictionary
            let nextBuildJSON = jobsDictionary["next_build"] as? NSDictionary

            if finishedBuildJSON == nil && nextBuildJSON == nil { continue }

            var finishedBuild: Build? = nil
            if let finishedBuildJSON = finishedBuildJSON {
                do {

                    let finishedBuildData = try JSONSerialization.data(withJSONObject: finishedBuildJSON, options: .prettyPrinted)
                    finishedBuild = buildDataDeserializer.deserialize(finishedBuildData).build
                } catch { }
            }

            var nextBuild: Build? = nil
            if let nextBuildJSON = nextBuildJSON {
                do {

                    let nextBuildData = try JSONSerialization.data(withJSONObject: nextBuildJSON, options: .prettyPrinted)
                    nextBuild = buildDataDeserializer.deserialize(nextBuildData).build
                } catch { }
            }


            jobs.append(Job(name: name, nextBuild: nextBuild, finishedBuild: finishedBuild))
        }

        return Observable.from(optional: jobs)
    }
}
