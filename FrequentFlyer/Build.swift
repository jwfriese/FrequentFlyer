struct Build {
    private(set) var id: Int
    private(set) var jobName: String
    private(set) var status: String
    private(set) var pipelineName: String
    
    init(id: Int, jobName: String, status: String, pipelineName: String) {
        self.id = id
        self.jobName = jobName
        self.status = status
        self.pipelineName = pipelineName
    }
}

extension Build: Equatable { }

func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.jobName == rhs.jobName &&
        lhs.status == rhs.status &&
        lhs.pipelineName == rhs.pipelineName
}
