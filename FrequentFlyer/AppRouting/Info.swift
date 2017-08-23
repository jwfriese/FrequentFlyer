import ObjectMapper

struct Info {
    let version: String

    init(version: String) {
        self.version = version
    }
}

extension Info: Equatable { }

func ==(lhs: Info, rhs: Info) -> Bool {
    return lhs.version == rhs.version
}

extension Info: ImmutableMappable {
    init(map: Map) throws {
        self.version = try map.value("version")
    }
}

