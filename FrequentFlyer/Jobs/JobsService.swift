import protocol Foundation.LocalizedError
import struct Foundation.URL
import struct Foundation.URLRequest
import RxSwift
import RxCocoa

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
            .do(onNext: { response in
                if response.statusCode == 401 {
                    throw AuthorizationError()
                }
            })
            .map { $0.body! }
            .flatMap { self.jobsDataDeserializer.deserialize($0) }
    }

    func getPublicJobs(forPipeline pipeline: Pipeline, concourseURL: String) -> Observable<[Job]> {
        let urlString = "\(concourseURL)/api/v1/teams/\(pipeline.teamName)/pipelines/\(pipeline.name)/jobs"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.jobsDataDeserializer.deserialize($0) }
    }
}
