struct Job {
    let name: String
    let nextBuild: Build?
    let finishedBuild: Build?

    init(name: String, nextBuild: Build?, finishedBuild: Build?) {
        self.name = name
        self.nextBuild = nextBuild
        self.finishedBuild = finishedBuild
    }
}

extension Job: Equatable { }

func ==(lhs: Job, rhs: Job) -> Bool {
    return lhs.name == rhs.name &&
        lhs.nextBuild == rhs.nextBuild &&
        lhs.finishedBuild == rhs.finishedBuild
}
