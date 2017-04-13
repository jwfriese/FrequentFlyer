import RxSwift

class StreamResult<T> {
    var elements: [T] = []
    var completed: Bool = false
    var error: Error?

    var disposeBag = DisposeBag()

    init(_ stream: Observable<T>) {
        stream
            .subscribe(onSingle)
            .addDisposableTo(disposeBag)
    }

    init(_ stream: Observable<[T]>) {
        stream
            .subscribe(onCollection)
            .addDisposableTo(disposeBag)
    }

    private func onSingle(_ event: Event<T>) {
        switch event {
        case .next(let e):
            elements.append(e)
        case .completed:
            completed = true
        case .error(let error):
            self.error = error
        }
    }

    private func onCollection(_ event: Event<[T]>) {
        switch event {
        case .next(let e):
            elements.append(contentsOf: e)
        case .completed:
            completed = true
        case .error(let error):
            self.error = error
        }
    }
}
