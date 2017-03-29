import Foundation
import RxSwift

class JobsDataDeserializer {
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
            jobs.append(Job(name: name))
        }

        return Observable.from(optional: jobs)
    }
}
