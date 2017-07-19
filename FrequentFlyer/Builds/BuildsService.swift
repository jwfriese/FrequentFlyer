import Foundation
import RxSwift

class BuildsService {
    var httpClient = HTTPClient()
    var buildsDataDeserializer = BuildsDataDeserializer()

    let disposeBag = DisposeBag()

    func getBuilds(forTarget target: Target, completion: (([Build]?, Error?) -> ())?) {
        let urlString = "\(target.api)/api/v1/builds"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(target.token.authValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        httpClient.perform(request: request)
            .subscribe(
                onNext: { response in
                    guard let completion = completion else { return }
                    guard let data = response.body else {
                        completion(nil, nil)
                        return
                    }

                    let result = self.buildsDataDeserializer.deserialize(data)
                    completion(result.value, result.error)
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
