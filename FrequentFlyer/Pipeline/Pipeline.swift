import ObjectMapper

struct Pipeline {
    let name: String
    let isPublic: Bool
    let teamName: String

    init(name: String, isPublic: Bool, teamName: String) {
        self.name = name
        self.isPublic = isPublic
        self.teamName = teamName
    }
}

extension Pipeline: Equatable { }

func ==(lhs: Pipeline, rhs: Pipeline) -> Bool {
    return lhs.name == rhs.name &&
        lhs.isPublic == rhs.isPublic &&
        lhs.teamName == rhs.teamName
}

extension Pipeline: ImmutableMappable {
    init(map: Map) throws {
        self.name = try map.value("name")
        self.isPublic = try map.value("public", using: StrictBoolTransform())
        self.teamName = try map.value("team_name")
    }
}
