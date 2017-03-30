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
            guard let buildJSON = jobsDictionary["finished_build"] as? NSDictionary else { continue }

            var builds: [Build] = []
            do {
                let buildData = try JSONSerialization.data(withJSONObject: buildJSON, options: .prettyPrinted)
                let deserializeResult = buildDataDeserializer.deserialize(buildData)
                if let build = deserializeResult.build {
                    builds.append(build)
                }
            } catch { }

            jobs.append(Job(name: name, builds: builds))
        }

        return Observable.from(optional: jobs)
    }
}
