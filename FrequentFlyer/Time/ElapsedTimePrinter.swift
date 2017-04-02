import Foundation

class ElapsedTimePrinter {
    var timepiece = Timepiece()

    func printTime(since timeSinceEpochInSeconds: TimeInterval) -> String {
        let inputAsDate = Date(timeIntervalSince1970: timeSinceEpochInSeconds)
        let now = timepiece.now()
        let timePassed = now.timeIntervalSince(inputAsDate)

        if timePassed < 0 {
            return "--"
        }

        if timePassed < 60 {
            return "\(UInt(timePassed))s ago"
        }

        let mins = timePassed / 60
        let secondsInHour = TimeInterval(3600)
        if timePassed < secondsInHour {
            return "\(UInt(mins))m ago"
        }

        let hours = mins / 60
        let secondsInDay = TimeInterval(86400)
        if timePassed < secondsInDay {
            return "\(UInt(hours))h ago"
        }

        let days = hours / 24

        return "\(UInt(days))d ago"
    }
}
