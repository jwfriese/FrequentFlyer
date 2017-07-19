import Foundation
import Result

class BuildDataDeserializer {
    var buildStatusInterpreter = BuildStatusInterpreter()

    func deserialize(_ data: Data) -> Result<Build, DeserializationError> {
        let buildJSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let buildJSON = buildJSONObject as? NSDictionary else {
            return Result.failure(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        guard let idObject = buildJSON.value(forKey: "id") else {
            return missingDataErrorCaseForKey("id")
        }

        guard let id = idObject as? Int else {
            return typeMismatchErrorCaseForKey("id", expectedType: "an integer")
        }

        guard let nameObject = buildJSON.value(forKey: "name") else {
            return missingDataErrorCaseForKey("name")
        }

        guard let name = nameObject as? String else {
            return typeMismatchErrorCaseForKey("name", expectedType: "a string")
        }

        guard let jobNameObject = buildJSON.value(forKey: "job_name") else {
            return missingDataErrorCaseForKey("job_name")
        }

        guard let jobName = jobNameObject as? String else {
            return typeMismatchErrorCaseForKey("job_name", expectedType: "a string")
        }

        guard let teamNameObject = buildJSON.value(forKey: "team_name") else {
            return missingDataErrorCaseForKey("team_name")
        }

        guard let teamName = teamNameObject as? String else {
            return typeMismatchErrorCaseForKey("team_name", expectedType: "a string")
        }

        guard let statusObject = buildJSON.value(forKey: "status") else {
            return missingDataErrorCaseForKey("status")
        }

        guard let status = statusObject as? String else {
            return typeMismatchErrorCaseForKey("status", expectedType: "a string")
        }

        guard let interpretedStatus = buildStatusInterpreter.interpret(status) else {
            return Result.failure(DeserializationError(details: "Failed to interpret '\(status)' as a build status.", type: .typeMismatch))
        }

        guard let pipelineNameObject = buildJSON.value(forKey: "pipeline_name") else {
            return missingDataErrorCaseForKey("pipeline_name")
        }

        guard let pipelineName = pipelineNameObject as? String else {
            return typeMismatchErrorCaseForKey("pipeline_name", expectedType: "a string")
        }

        let startTimeObject = buildJSON.value(forKey: "start_time")
        guard let startTime = startTimeObject as? UInt else {
            return typeMismatchErrorCaseForKey("start_time", expectedType: "an unsigned integer")
        }

        let endTimeObject = buildJSON.value(forKey: "end_time")
        guard let endTime = endTimeObject as? UInt else {
            return typeMismatchErrorCaseForKey("end_time", expectedType: "an unsigned integer")
        }

        let build = Build(id: id,
                          name: name,
                          teamName: teamName,
                          jobName: jobName,
                          status: interpretedStatus,
                          pipelineName: pipelineName,
                          startTime: startTime,
                          endTime: endTime
        )

        return Result.success(build)
    }

    fileprivate func missingDataErrorCaseForKey(_ key: String) -> Result<Build, DeserializationError> {
        let error = DeserializationError(details: "Missing required '\(key)' field", type: .missingRequiredData)
        return Result.failure(error)
    }

    fileprivate func typeMismatchErrorCaseForKey(_ key: String, expectedType: String) -> Result<Build, DeserializationError> {
        let error = DeserializationError(details: "Expected value for '\(key)' field to be \(expectedType)", type: .typeMismatch)
        return Result.failure(error)
    }
}
