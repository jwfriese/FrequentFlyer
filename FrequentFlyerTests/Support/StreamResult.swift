import RxSwift

class StreamResult<T> {
    var elements: [T] = []
    var completed: Bool = false
    var error: Error?
    
    private let disposeBag = DisposeBag()
    
    init(_ stream: Observable<T>) {
        stream
            .subscribe(on)
            .addDisposableTo(disposeBag)
    }
    
    private func on(_ event: Event<T>) {
        switch event {
        case .next(let e):
            elements.append(e)
        case .completed:
            completed = true
        case .error(let error):
            self.error = error
        }
    }
}
