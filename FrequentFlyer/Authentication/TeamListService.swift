import struct Foundation.URLRequest
import struct Foundation.URL
import RxSwift

class TeamListService {
    var httpClient = HTTPClient()
    var teamsDataDeserializer = TeamsDataDeserializer()

    func getTeams(forConcourseWithURL concourseURL: String) -> Observable<[String]> {
        let urlString = "\(concourseURL)/api/v1/teams"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.teamsDataDeserializer.deserialize($0) }
    }
}
