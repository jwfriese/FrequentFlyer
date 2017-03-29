struct Job {
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Job: Equatable { }

func ==(lhs: Job, rhs: Job) -> Bool {
    return lhs.name == rhs.name
}
