import Foundation

class TargetListDataDeserializer {
    func deserialize(data: NSData) -> (targetList: [Target]?, error: DeserializationError?) {
        let targetListJSON = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String : AnyObject]
        if targetListJSON == nil {
            return (nil, DeserializationError(details: "Input data must be interpretable as JSON", type: .InvalidInputFormat))
        }
        
        let targetJSONArray = targetListJSON!["targets"] as? [[String : AnyObject]]
        if targetJSONArray == nil {
            return (nil, DeserializationError(details: "Missing required 'targets' key", type: .MissingRequiredData))
        }
        
        var targetList = [Target]()
        for targetJSON in targetJSONArray! {
            guard let name = targetJSON["name"] as? String else { continue }
            guard let api = targetJSON["api"] as? String else { continue }
            guard let team = targetJSON["team"] as? String else { continue }
            guard let tokenJSON = targetJSON["token"] as? [String : String] else { continue }
            guard let tokenValue = tokenJSON["value"] else { continue }
            
            targetList.append(Target(name: name, api: api, teamName: team, token: Token(value: tokenValue)))
        }
        
        return (targetList, nil)
    }
}