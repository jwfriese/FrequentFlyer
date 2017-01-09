import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var logOutputView: UITextView?

    var sseService = SSEService()
    var logsStylingParser = LogsStylingParser()

    var target: Target?
    var build: Build?

    class var storyboardIdentifier: String { get { return "LogsViewController" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let target = target else { return }
        guard let build = build else { return }

        let connection = sseService.openSSEConnection(target: target, build: build)
        connection.onLogsReceived = onMessagesReceived
    }

    fileprivate var onMessagesReceived: (([LogEvent]) -> ()) {
        get {
            return { messages in
                guard let logOutputView = self.logOutputView else { return }

                let existingText = logOutputView.text!
                var textToAdd = ""
                for message in messages {
                    let parsedPayload = self.logsStylingParser.stripStylingCoding(originalString: message.payload)
                    textToAdd += parsedPayload
                    textToAdd += "\n"
                }

                DispatchQueue.main.async {
                    logOutputView.text = existingText + textToAdd
                }
            }
        }
    }
}
