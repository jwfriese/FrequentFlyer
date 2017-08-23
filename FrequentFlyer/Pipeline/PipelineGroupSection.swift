import RxDataSources

struct PipelineGroupSection: SectionModelType {
    typealias Item = Pipeline
    var items: [Item]

    init() {
        self.items = []
    }

    init(original: PipelineGroupSection, items: [Item]) {
        self = original
        self.items = items
    }
}

