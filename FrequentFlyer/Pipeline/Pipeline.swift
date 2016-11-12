struct Pipeline {
    fileprivate(set) var name: String

    init(name: String) {
        self.name = name
    }
}

extension Pipeline: Equatable { }

func ==(lhs: Pipeline, rhs: Pipeline) -> Bool {
    return lhs.name == rhs.name
}
