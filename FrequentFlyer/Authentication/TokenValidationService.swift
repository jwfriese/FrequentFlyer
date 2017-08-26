import Foundation
import RxSwift

class TokenValidationService {
    var httpClient = HTTPClient()

    let disposeBag = DisposeBag()

    func validate(token: Token, forConcourse concourseURLString: String, completion: ((Error?) -> ())?) {
        guard let url = URL(string: "\(concourseURLString)/api/v1/containers") else {
            Logger.logError(
                InitializationError.serviceURL(functionName: #function,
                                               data: ["concourseURL" : concourseURLString]
                )
            )
            return
        }

        guard let completion = completion else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token.authValue, forHTTPHeaderField: "Authorization")

        httpClient.perform(request: request)
            .subscribe(
                onNext: {  _ in completion(nil) },
                onError: { error in completion(error) },
                onCompleted: nil,
                onDisposed: nil
        )
        .addDisposableTo(disposeBag)
    }
}
