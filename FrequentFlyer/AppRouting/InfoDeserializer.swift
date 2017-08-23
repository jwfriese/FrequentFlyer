import Foundation
import RxSwift
import ObjectMapper

class InfoDeserializer {
    func deserialize(_ infoData: Data) -> Observable<Info> {
        guard let jsonString = String(data: infoData, encoding: String.Encoding.utf8) else {
            return Observable.error(MapError(key: "", currentValue: "", reason: "Could not interpret response from info endpoint as a UTF-8 string"))
        }

        var info: Info
        do {
            try info = Info(JSONString: jsonString)
        } catch let error {
            return Observable.error(error)
        }

        return Observable.just(info)
    }
}
