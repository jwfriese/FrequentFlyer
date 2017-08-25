import Foundation
import RxSwift

class PublicPipelinesService {
    var httpClient = HTTPClient()
    var pipelineDataDeserializer = PipelineDataDeserializer()

    func getPipelines(forConcourseWithURL concourseURL: String) -> Observable<[Pipeline]> {
        let urlString = "\(concourseURL)/api/v1/pipelines"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .do(onNext: { try self.throwIfNotAuthorized($0) })
            .map({ try self.getResponseBodyFor($0) })
            .flatMap { self.pipelineDataDeserializer.deserialize($0) }
    }

    private func throwIfNotAuthorized(_ response: HTTPResponse) throws {
        if response.statusCode == 401 {
            throw AuthorizationError()
        }
    }

    private func getResponseBodyFor(_ response: HTTPResponse) throws -> Data {
            if let body = response.body {
                return body
            }

        throw UnexpectedError("Failed to find body in response for public pipelines endpoint")
    }
}
