import struct Foundation.URLRequest
import struct Foundation.URL
import RxSwift

class TeamListService {
    var httpClient = HTTPClient()
    var teamsDataDeserializer = TeamsDataDeserializer()

    func getTeams(forConcourseWithURL concourseURL: String) -> Observable<[String]> {
        guard let url = URL(string: "\(concourseURL)/api/v1/teams") else {
            Logger.logError(
                InitializationError.serviceURL(functionName: #function,
                                               data: ["concourseURL" : concourseURL]
                )
            )
            return Observable.empty()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.teamsDataDeserializer.deserialize($0) }
    }
}
