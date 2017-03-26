import Foundation
import RxSwift

class BasicAuthTokenService {
    var httpClient = HTTPClient()
    var tokenDataDeserializer = TokenDataDeserializer()

    func getToken(forTeamWithName teamName: String, concourseURL: String,
                  username: String, password: String) -> Observable<Token> {
        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let usernamePasswordData = "\(username):\(password)".data(using: String.Encoding.utf8)
        let base64EncodedAuthenticationDetails = usernamePasswordData!.base64EncodedString(options: NSData.Base64EncodingOptions())

        request.addValue("Basic \(base64EncodedAuthenticationDetails)", forHTTPHeaderField: "Authorization")

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.tokenDataDeserializer.deserialize($0) }
    }
}
