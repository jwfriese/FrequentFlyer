import struct Foundation.URLRequest
import struct Foundation.URL
import RxSwift

class InfoService {
    var httpClient = HTTPClient()
    var infoDeserializer = InfoDeserializer()

    func getInfo(forConcourseWithURL concourseURL: String) -> Observable<Info> {
        let urlString = concourseURL + "/api/v1/info"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        return httpClient.perform(request: request)
            .map { $0.body! }
            .flatMap { self.infoDeserializer.deserialize($0) }
    }
}
