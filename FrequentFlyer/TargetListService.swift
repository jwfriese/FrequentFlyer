import Foundation

class TargetListService {
    var nsUserDefaultsService: NSUserDefaultsService?
    var targetListDataDeserializer: TargetListDataDeserializer?

    func getTargetList() -> [Target] {
        guard let nsUserDefaultsService = nsUserDefaultsService else { return [] }
        guard let targetListDataDeserializer = targetListDataDeserializer else { return [] }

        guard let storedTargetsData = nsUserDefaultsService.getDataForKey("targets") else {
            return []
        }

        let deserializationResult = targetListDataDeserializer.deserialize(storedTargetsData)
        return deserializationResult.targetList!
    }
}
