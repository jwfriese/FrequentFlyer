import Foundation
import class UIKit.UIApplication
import RxSwift
import RxCocoa

class HTTPClient: NSObject {
    var session: URLSession = URLSession()
    var sslTrustService = SSLTrustService()

    override init() {
        super.init()
        let sessionConfig = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
    }

    func perform(request: URLRequest) -> Observable<HTTPResponse> {
        return session.rx.response(request: request)
            .do(onSubscribed: {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            })
            .map { response, data in
                return HTTPResponseImpl(body: data, statusCode: response.statusCode)
            }
            .do(onError: { error in
                print(error)
                Logger.logError(error)
                let isSSLTroubleCode = ((error as NSError).code == -1202) || ((error as NSError).code == -1200)
                if isSSLTroubleCode && (error as NSError).domain == "NSURLErrorDomain" {
                    throw HTTPError.sslValidation
                }
            })
            .do(onDispose: {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
    }
}

extension HTTPClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return }

        let baseURL = "https://" + challenge.protectionSpace.host
        let isServerTrustAuth = challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
        let isWhitelistedBaseURL = sslTrustService.hasRegisteredTrust(forBaseURL: baseURL)
        if isServerTrustAuth && isWhitelistedBaseURL {
            challenge.sender?.use(URLCredential(trust: serverTrust), for: challenge)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        }

        completionHandler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
    }
}
