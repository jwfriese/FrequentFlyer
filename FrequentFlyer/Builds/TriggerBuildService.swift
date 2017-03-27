import Foundation
import RxSwift

class TriggerBuildService {
    var httpClient = HTTPClient()
    var buildDataDeserializer = BuildDataDeserializer()

    let disposeBag = DisposeBag()

    func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String, completion: ((Build?, Error?) -> ())?) {
        let urlString = "\(target.api)/api/v1/teams/\(target.teamName)/pipelines/\(pipelineName)/jobs/\(jobName)/builds"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        request.allHTTPHeaderFields?["Authorization"] = target.token.authValue

        httpClient.doRequest(request as URLRequest) { response, error in
            guard let completion = completion else { return }
            guard let data = response?.body else {
                completion(nil, error)
                return
            }

            let deserializationResult = self.buildDataDeserializer.deserialize(data)
            completion(deserializationResult.build, deserializationResult.error)
        }

        httpClient.perform(request: request)
            .subscribe(
                onNext: { response in
                    guard let completion = completion else { return }
                    guard let data = response.body else {
                        completion(nil, nil)
                        return
                    }

                    let deserializationResult = self.buildDataDeserializer.deserialize(data)
                    completion(deserializationResult.build, deserializationResult.error)
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
