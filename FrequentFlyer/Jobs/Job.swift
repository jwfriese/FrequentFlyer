struct Job {
    var name: String
    var builds: [Build]

    init(name: String, builds: [Build]) {
        self.name = name
        self.builds = builds
    }
}

extension Job: Equatable { }

func ==(lhs: Job, rhs: Job) -> Bool {
    return lhs.name == rhs.name &&
        lhs.builds == rhs.builds
}
