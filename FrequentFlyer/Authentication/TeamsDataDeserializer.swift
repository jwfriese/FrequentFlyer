import struct Foundation.Data
import class Foundation.NSDictionary
import class Foundation.JSONSerialization
import RxSwift

class TeamsDataDeserializer {
    func deserialize(_ data: Data) -> Observable<[String]> {
        var teamsJSONObject: Any?
        do {
            teamsJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        var teamNames = [String]()

        guard let teamsJSON = teamsJSONObject as? Array<NSDictionary> else {
            return Observable.error(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        for teamsDictionary in teamsJSON {
            guard let nameString = teamsDictionary["name"] as? String else { continue }

            teamNames.append(nameString)
        }

        return Observable.from(optional: teamNames)
    }
}
