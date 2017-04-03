import Foundation

class BuildStatusInterpreter {
    func interpret(_ statusString: String) -> BuildStatus? {
        let trimmedStatusString = statusString.trimmingCharacters(in: CharacterSet.whitespaces)
        let toLoweredStatusString = trimmedStatusString.lowercased()

        var buildStatus: BuildStatus?
        switch toLoweredStatusString {
        case "pending":
            buildStatus = .pending
        case "started":
            buildStatus = .started
        case "succeeded":
            buildStatus = .succeeded
        case "failed":
            buildStatus = .failed
        case "errored":
            buildStatus = .errored
        case "aborted":
            buildStatus = .aborted
        case "paused":
            buildStatus = .paused
        default:
            break
        }

        return buildStatus
    }
}
