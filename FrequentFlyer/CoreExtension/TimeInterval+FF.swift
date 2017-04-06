import Foundation

extension TimeInterval {
    init?(_ unsignedInteger: UInt?) {
        guard let unwrappedInput = unsignedInteger else {
            return nil
        }

        self = TimeInterval(unwrappedInput)
    }
}
