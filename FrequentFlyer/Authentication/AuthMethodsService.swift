import Foundation
import RxSwift

class AuthMethodsService {
    var httpClient = HTTPClient()
    var authMethodsDataDeserializer = AuthMethodDataDeserializer()

    func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<[AuthMethod]> {
        guard let url = URL(string: "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods") else {
            Logger.logError(
                InitializationError.serviceURL(functionName: #function,
                                               data: ["concourseURL" : concourseURL, "teamName" : teamName]
                )
            )
            return Observable.empty()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.authMethodsDataDeserializer.deserialize($0) }
    }
}
