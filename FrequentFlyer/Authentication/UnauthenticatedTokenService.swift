import Foundation
import RxSwift

class UnauthenticatedTokenService {
    var httpClient = HTTPClient()
    var tokenDataDeserializer = TokenDataDeserializer()
    let disposeBag = DisposeBag()

    func getUnauthenticatedToken(forTeamName teamName: String, concourseURL: String, completion: ((Token?, Error?) -> ())?) {
        let urlString = concourseURL + "/api/v1/teams/\(teamName)/auth/token"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        httpClient.doRequest(request) { response, error in
            guard let completion = completion else { return }
            guard let data = response?.body else {
                completion(nil, error)
                return
            }

            let deserializationResult = self.tokenDataDeserializer.deserializeold(data)
            completion(deserializationResult.token, deserializationResult.error)
        }

        let $ = httpClient.perform(request: request)
        $.subscribe(
            onNext: { response in
                guard let completion = completion else { return }
                guard let data = response.body else {
                    completion(nil, nil)
                    return
                }

                let deserializationResult = self.tokenDataDeserializer.deserializeold(data)
                completion(deserializationResult.token, deserializationResult.error)
        },
            onError: { error in
                guard let completion = completion else { return }
                completion(nil, error)
        },
            onCompleted: nil,
            onDisposed: nil
        )
            .addDisposableTo(disposeBag)
    }
}
