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
            .do(onNext: { response in
                if response.statusCode == 401 {
                    throw AuthorizationError()
                }
            })
            .map { try self.getResponseBodyFor($0) }
            .map { data in
                let result = self.pipelineDataDeserializer.deserialize(data)
                if let pipelines = result.value {
                    return pipelines
                }
                if let error = result.error {
                    throw error
                }

                throw BasicError(details: "Complete failure in pipeline data deserialization")
        }
    }

    private func getResponseBodyFor(_ response: HTTPResponse) throws -> Data {
            if let body = response.body {
                return body
            }

        throw UnexpectedError("Failed to find body in response for public pipelines endpoint")
    }
}
