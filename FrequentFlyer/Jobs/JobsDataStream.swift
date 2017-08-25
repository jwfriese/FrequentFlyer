import RxSwift

protocol JobsDataStream {
    func open(forPipeline: Pipeline) -> Observable<[JobGroupSection]>
}
