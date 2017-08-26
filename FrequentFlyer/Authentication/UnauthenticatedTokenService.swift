import Foundation
import RxSwift

class UnauthenticatedTokenService {
    var httpClient = HTTPClient()
    var tokenDataDeserializer = TokenDataDeserializer()
    let disposeBag = DisposeBag()

    func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String) -> Observable<Token> {
        guard let url = URL(string: concourseURL + "/api/v1/teams/\(teamName)/auth/token") else {
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
            .flatMap { self.tokenDataDeserializer.deserialize($0) }
            .asObservable()
    }
}
