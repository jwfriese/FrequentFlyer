struct Build {
    let id: Int
    let name: String
    let teamName: String
    let jobName: String
    let status: BuildStatus
    let pipelineName: String
    let endTime: UInt

    init(id: Int,
         name: String,
         teamName: String,
         jobName: String,
         status: BuildStatus,
         pipelineName: String,
         endTime: UInt) {

        self.id = id
        self.name = name
        self.teamName = name
        self.jobName = jobName
        self.status = status
        self.pipelineName = pipelineName
        self.endTime = endTime
    }
}

extension Build: Equatable { }

func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.name == rhs.name &&
        lhs.teamName == rhs.teamName &&
        lhs.jobName == rhs.jobName &&
        lhs.status == rhs.status &&
        lhs.pipelineName == rhs.pipelineName &&
        lhs.endTime == rhs.endTime
}
