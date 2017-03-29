import Foundation
import RxSwift

class JobsService {
    var httpClient = HTTPClient()
    var jobsDataDeserializer = JobsDataDeserializer()

    func getJobs(forTarget target: Target, pipeline: Pipeline) -> Observable<[Job]> {
        let urlString = "\(target.api)/api/v1/teams/\(target.teamName)/pipelines/\(pipeline.name)/jobs"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(target.token.authValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.jobsDataDeserializer.deserialize($0) }
    }
}
