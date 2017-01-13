import Foundation
import RxSwift

class AuthMethodsService {
    var httpClient = HTTPClient()
    var authMethodsDataDeserializer = AuthMethodDataDeserializer()
    
    func getMethods(forTeamName teamName: String, concourseURL: String) -> Observable<AuthMethod> {
        return Observable.create { observer in
            let urlString = "\(concourseURL)/api/v1/teams/\(teamName)/auth/methods"
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            _ = self.httpClient.doRequest(request as URLRequest) { response, error in
                guard let data = response?.body else {
                    observer.onError(error!)
                    return
                }
                
                let deserializationResult = self.authMethodsDataDeserializer.deserialize(data)
                if let error = deserializationResult.error {
                    observer.onError(error)
                    return
                }
                
                for authMethod in deserializationResult.authMethods! {
                    observer.onNext(authMethod)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
