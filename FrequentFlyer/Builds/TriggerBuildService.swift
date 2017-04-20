import Foundation
import RxSwift

class TriggerBuildService {
    var httpClient = HTTPClient()
    var buildDataDeserializer = BuildDataDeserializer()

    let disposeBag = DisposeBag()

    func triggerBuild(forTarget target: Target, forJob jobName: String, inPipeline pipelineName: String) -> Observable<Build> {
        let urlString = "\(target.api)/api/v1/teams/\(target.teamName)/pipelines/\(pipelineName)/jobs/\(jobName)/builds"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        request.allHTTPHeaderFields?["Authorization"] = target.token.authValue
        
        return httpClient.perform(request: request)
            .do(onNext: { response in
                if response.statusCode == 401 {
                    throw AuthorizationError()
                }
            })
            .map { $0.body! }
            .flatMap { self.buildDataDeserializer.deserialize($0) }
    }
}
