import Foundation
import RxSwift

class PipelinesService {
    var httpClient = HTTPClient()
    var pipelineDataDeserializer = PipelineDataDeserializer()

    let disposeBag = DisposeBag()
    func getPipelines(forTarget target: Target) -> Observable<[Pipeline]> {
        guard let url = URL(string: target.api + "/api/v1/teams/" + target.teamName + "/pipelines") else {
            return Observable.empty()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(target.token.authValue, forHTTPHeaderField: "Authorization")
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
