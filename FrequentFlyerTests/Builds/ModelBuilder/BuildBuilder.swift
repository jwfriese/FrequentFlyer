@testable import FrequentFlyer

class BuildBuilder {
    private var nextId = 1
    private var nextName = "name"
    private var nextTeamName = "teamName"
    private var nextJobName = "jobName"
    private var nextStatus = BuildStatus.pending
    private var nextPipelineName = "pipelineName"
    private var nextStartTime: UInt? = UInt(50)
    private var nextEndTime: UInt? = UInt(100)

    private func reset() {
        nextId = 1
        nextName = "name"
        nextTeamName = "teamName"
        nextJobName = "jobName"
        nextStatus = BuildStatus.pending
        nextPipelineName = "pipelineName"
        nextStartTime = UInt(50)
        nextEndTime = UInt(100)
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
            pipelineName: nextPipelineName,
            startTime: nextStartTime,
            endTime: nextEndTime
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

    func withStatus(_ status: BuildStatus) -> BuildBuilder {
        nextStatus = status
        return self
    }

    func withPipelineName(_ pipelineName: String) -> BuildBuilder {
        nextPipelineName = pipelineName
        return self
    }

    func withStartTime(_ startTime: UInt?) -> BuildBuilder {
        nextStartTime = startTime
        return self
    }

    func withEndTime(_ endTime: UInt?) -> BuildBuilder {
        nextEndTime = endTime
        return self
    }
}
