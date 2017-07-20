import RxDataSources

struct JobGroupSection: SectionModelType {
    typealias Item = Job
    var items: [Item]

    init() {
        self.items = []
    }

    init(original: JobGroupSection, items: [Item]) {
        self = original
        self.items = items
    }
}
