struct Build {
    private(set) var id: Int
    private(set) var jobName: String
    private(set) var status: String
    
    init(id: Int, jobName: String, status: String) {
        self.id = id
        self.jobName = jobName
        self.status = status
    }
}

extension Build: Equatable { }

func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.jobName == rhs.jobName && lhs.status == rhs.status
}
