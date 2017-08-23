import Darwin

struct TestError: Error {
    // Apparently I have to do something like this to make sure these things are unique.
    let randomId = Int(arc4random_uniform(100000) + 1)

    var localizedDescription: String {
        return "test error"
    }
}

extension TestError: Equatable {}

func==(lhs: TestError, rhs: TestError) -> Bool {
    return
        lhs.randomId == rhs.randomId
}
