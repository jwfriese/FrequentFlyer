struct Job {
    let name: String
    let nextBuild: Build?
    let finishedBuild: Build?
    let groups: [String]

    init(name: String,
         nextBuild: Build?,
         finishedBuild: Build?,
         groups: [String]) {
        self.name = name
        self.nextBuild = nextBuild
        self.finishedBuild = finishedBuild
        self.groups = groups
    }
}

extension Job: Equatable { }

func ==(lhs: Job, rhs: Job) -> Bool {
    return lhs.name == rhs.name &&
        lhs.nextBuild == rhs.nextBuild &&
        lhs.finishedBuild == rhs.finishedBuild &&
        lhs.groups == rhs.groups
}
