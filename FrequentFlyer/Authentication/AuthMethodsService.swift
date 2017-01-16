import Foundation
import RxSwift

class AuthMethodsService {
    var httpClient = HTTPClient()
    var authMethodsDataDeserializer = AuthMethodDataDeserializer()

    func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<AuthMethod> {
        let dataSubject = PublishSubject<Data>()
        let urlString = "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        _ = self.httpClient.doRequest(request as URLRequest) { response, error in
            if let error = error {
                dataSubject.onError(error)
                return
            }

            dataSubject.onNext(response!.body!)
        }

        return dataSubject.flatMap {
            data in
            self.authMethodsDataDeserializer.deserialize(data)
            }
    }
}
