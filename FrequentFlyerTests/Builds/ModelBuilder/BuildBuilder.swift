@testable import FrequentFlyer

class BuildBuilder {
    private var nextId = 1
    private var nextName = "name"
    private var nextTeamName = "teamName"
    private var nextJobName = "jobName"
    private var nextStatus = "status"
    private var nextPipelineName = "pipelineName"

    private func reset() {
        nextId = 1
        nextName = "name"
        nextTeamName = "teamName"
        nextJobName = "jobName"
        nextStatus = "status"
        nextPipelineName = "pipelineName"
    }

    init() {
        reset()
    }

    func build() -> Build {
        let build = Build(
            id: nextId,
            name: nextName,
            teamName: nextTeamName,
            jobName: nextJobName,
            status: nextStatus,
            pipelineName: nextPipelineName
        )

        reset()
        return build
    }

    func withId(_ id: Int) -> BuildBuilder {
        nextId = id
        return self
    }

    func withName(_ name: String) -> BuildBuilder {
        nextName = name
        return self
    }

    func withTeamName(_ teamName: String) -> BuildBuilder {
        nextTeamName = teamName
        return self
    }

    func withJobName(_ jobName: String) -> BuildBuilder {
        nextJobName = jobName
        return self
    }

    func withStatus(_ status: String) -> BuildBuilder {
        nextStatus = status
        return self
    }

    func withPipelineName(_ pipelineName: String) -> BuildBuilder {
        nextPipelineName = pipelineName
        return self
    }
}
