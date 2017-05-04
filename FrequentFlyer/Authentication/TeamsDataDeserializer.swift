import struct Foundation.Data
import class Foundation.NSDictionary
import class Foundation.JSONSerialization
import RxSwift

class TeamsDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[String]> {
        let teamsJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let teamsJSON = teamsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        let teamNames = teamsJSON.flatMap { teamsDictionary in
            return teamsDictionary["name"] as? String
        }

        return Observable.from(optional: teamNames)
    }
}
