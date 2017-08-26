import Foundation
import RxSwift
import Result

class TriggerBuildService {
    var httpClient = HTTPClient()
    var buildDataDeserializer = BuildDataDeserializer()

    let disposeBag = DisposeBag()

    func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String) -> Observable<Build> {
        guard let url = URL(string: "\(target.api)/api/v1/teams/\(target.teamName)/pipelines/\(pipelineName)/jobs/\(jobName)/builds") else {
            Logger.logError(
                InitializationError.serviceURL(functionName: #function,
                                               data: [
                                                "target" : target,
                                                "pipelineName" : pipelineName,
                                                "jobName" : jobName
                    ]
                )
            )
            return Observable.empty()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        request.allHTTPHeaderFields?["Authorization"] = target.token.authValue

        return httpClient.perform(request: request)
            .map { response in
                guard let data = response.body else {
                    throw BasicError(details: "Expected data to return from call to retrigger build")
                }

                let deserializationResult = self.buildDataDeserializer.deserialize(data)
                if let build = deserializationResult.value {
                    return build
                } else if let error = deserializationResult.error {
                    throw error
                }

                throw BasicError(details: "Expected data to return from call to retrigger build")
            }
    }
}
