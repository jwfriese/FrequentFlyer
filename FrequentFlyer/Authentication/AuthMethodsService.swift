import Foundation
import RxSwift

extension ObservableType {
    func replayAllAndConnect() -> Observable<Self.E> {
        let replayObservable = self.replayAll()
        _ = replayObservable.connect()
        return replayObservable
    }
}

class AuthMethodsService {
    var httpClient = HTTPClient()
    var authMethodsDataDeserializer = AuthMethodDataDeserializer()

    func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<AuthMethod> {
        return Observable.create { observer in
            let urlString = "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods"
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            self.httpClient.doRequest(request as URLRequest) { response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                observer.onNext(response!.body!)
                observer.onCompleted()
            }
            return Disposables.create()
            }
            .flatMap { self.authMethodsDataDeserializer.deserialize($0) }
            .replayAllAndConnect()
    }
}
