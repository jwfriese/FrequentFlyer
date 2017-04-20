import Foundation
import RxSwift

class BuildDataDeserializer {
    var buildStatusInterpreter = BuildStatusInterpreter()

    func deserialize(_ data: Data) -> ReplaySubject<Build> {
        let $ = ReplaySubject<Build>.createUnbounded()
        
        var buildJSONObject: Any?
        do {
            buildJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let buildJSON = buildJSONObject as? NSDictionary else {
            $.onError(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
            return $
        }

        guard let idObject = buildJSON.value(forKey: "id") else {
            $.onError(missingDataErrorCaseForKey("id"))
            return $
        }

        guard let id = idObject as? Int else {
            $.onError(typeMismatchErrorCaseForKey("id", expectedType: "an integer"))
            return $
        }

        guard let nameObject = buildJSON.value(forKey: "name") else {
            $.onError(missingDataErrorCaseForKey("name"))
            return $
        }

        guard let name = nameObject as? String else {
            $.onError(typeMismatchErrorCaseForKey("name", expectedType: "a string"))
            return $
        }

        guard let jobNameObject = buildJSON.value(forKey: "job_name") else {
            $.onError(missingDataErrorCaseForKey("job_name"))
            return $
        }

        guard let jobName = jobNameObject as? String else {
            $.onError(typeMismatchErrorCaseForKey("job_name", expectedType: "a string"))
            return $
        }

        guard let teamNameObject = buildJSON.value(forKey: "team_name") else {
            $.onError(missingDataErrorCaseForKey("team_name"))
            return $
        }

        guard let teamName = teamNameObject as? String else {
            $.onError(typeMismatchErrorCaseForKey("team_name", expectedType: "a string"))
            return $
        }

        guard let statusObject = buildJSON.value(forKey: "status") else {
            $.onError(missingDataErrorCaseForKey("status"))
            return $
        }

        guard let status = statusObject as? String else {
            $.onError(typeMismatchErrorCaseForKey("status", expectedType: "a string"))
            return $
        }

        guard let interpretedStatus = buildStatusInterpreter.interpret(status) else {
            $.onError(DeserializationError(details: "Failed to interpret '\(status)' as a build status.", type: .typeMismatch))
            return $
        }

        guard let pipelineNameObject = buildJSON.value(forKey: "pipeline_name") else {
            $.onError(missingDataErrorCaseForKey("pipeline_name"))
            return $
        }

        guard let pipelineName = pipelineNameObject as? String else {
            $.onError(typeMismatchErrorCaseForKey("pipeline_name", expectedType: "a string"))
            return $
        }

        let startTimeObject = buildJSON.value(forKey: "start_time")
        var startTime: UInt? = nil
        if startTimeObject != nil {
            guard let castedStartTime = startTimeObject as? UInt else {
                $.onError(typeMismatchErrorCaseForKey("start_time", expectedType: "an unsigned integer"))
                return $
            }

            startTime = castedStartTime
        }

        let endTimeObject = buildJSON.value(forKey: "end_time")
        var endTime: UInt? = nil
        if endTimeObject != nil {
            guard let castedEndTime = endTimeObject as? UInt else {
                $.onError(typeMismatchErrorCaseForKey("end_time", expectedType: "an unsigned integer"))
                return $
            }

            endTime = castedEndTime
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

        $.onNext(build)
        return $
    }

    fileprivate func missingDataErrorCaseForKey(_ key: String) -> DeserializationError {
        return DeserializationError(details: "Missing required '\(key)' field", type: .missingRequiredData)
    }

    fileprivate func typeMismatchErrorCaseForKey(_ key: String, expectedType: String) -> DeserializationError {
        return DeserializationError(details: "Expected value for '\(key)' field to be \(expectedType)", type: .typeMismatch)
    }
}
