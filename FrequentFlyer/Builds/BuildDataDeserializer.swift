import Foundation

class BuildDataDeserializer {
    func deserialize(data: NSData) -> (build: Build?, error: DeserializationError?) {
        var buildJSONObject: AnyObject?
        do {
            buildJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch { }

        guard let buildJSON = buildJSONObject as? NSDictionary else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat))
        }

        guard let idObject = buildJSON.valueForKey("id") else {
            return missingDataErrorCaseForKey("id")
        }

        guard let id = idObject as? Int else {
            return typeMismatchErrorCaseForKey("id", expectedType: "an integer")
        }

        guard let jobNameObject = buildJSON.valueForKey("job_name") else {
            return missingDataErrorCaseForKey("job_name")
        }

        guard let jobName = jobNameObject as? String else {
            return typeMismatchErrorCaseForKey("job_name", expectedType: "a string")
        }

        guard let statusObject = buildJSON.valueForKey("status") else {
            return missingDataErrorCaseForKey("status")
        }

        guard let status = statusObject as? String else {
            return typeMismatchErrorCaseForKey("status", expectedType: "a string")
        }

        guard let pipelineNameObject = buildJSON.valueForKey("pipeline_name") else {
            return missingDataErrorCaseForKey("pipeline_name")
        }

        guard let pipelineName = pipelineNameObject as? String else {
            return typeMismatchErrorCaseForKey("pipeline_name", expectedType: "a string")
        }

        let build = Build(id: id,
                          jobName: jobName,
                          status: status,
                          pipelineName: pipelineName)

        return (build, nil)
    }

    private func missingDataErrorCaseForKey(key: String) -> (Build?, DeserializationError?) {
        let error = DeserializationError(details: "Missing required '\(key)' field", type: .MissingRequiredData)
        return (nil, error)
    }

    private func typeMismatchErrorCaseForKey(key: String, expectedType: String) -> (Build?, DeserializationError?) {
        let error = DeserializationError(details: "Expected value for '\(key)' field to be \(expectedType)", type: .TypeMismatch)
        return (nil, error)
    }
}
