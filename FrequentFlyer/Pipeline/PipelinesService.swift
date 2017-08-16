import Foundation
import RxSwift

class PipelinesService {
    var httpClient = HTTPClient()
    var pipelineDataDeserializer = PipelineDataDeserializer()

    let disposeBag = DisposeBag()

    func getPipelines(forTarget target: Target, completion: (([Pipeline]?, Error?) -> ())?) {
        guard let url = URL(string: target.api + "/api/v1/teams/" + target.teamName + "/pipelines") else {
            return
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(target.token.authValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        httpClient.perform(request: request)
            .subscribe(
                onNext: { response in
                    guard let completion = completion else { return }
                    guard let data = response.body else {
                        completion(nil, UnexpectedError("Received response from \(PipelinesService.self) with no response body: \(response)"))
                        return
                    }

                    if response.statusCode == 401 {
                        completion(nil, AuthorizationError())
                        return
                    }

                    let deserializationResult = self.pipelineDataDeserializer.deserialize(data)
                    if let pipelines = deserializationResult.value {
                        completion(pipelines, nil)
                    } else if let error = deserializationResult.error {
                        completion(nil, error)
                    }
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
