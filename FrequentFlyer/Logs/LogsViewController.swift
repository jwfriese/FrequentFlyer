import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var logOutputView: UITextView?
    @IBOutlet weak var jumpToBottomButton: RoundedButton?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var sseService = SSEService()
    var logsStylingParser = LogsStylingParser()

    var target: Target?
    var build: Build?

    class var storyboardIdentifier: String { get { return "Logs" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        logOutputView?.text = ""
        logOutputView?.backgroundColor = Style.Colors.logsBackground
        logOutputView?.textContainerInset = UIEdgeInsets(top: 32, left: 32, bottom: 0, right:32)
        logOutputView?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logOutputView?.font = Style.Fonts.bold(withSize: 14)

        loadingIndicator?.color = Style.Colors.lightLoadingIndicator
        loadingIndicator?.hidesWhenStopped = true

        jumpToBottomButton?.setUp(withTitleText: "v",
                                  titleFont: Style.Fonts.button,
                                  controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                  controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )
    }

    func fetchLogs() {
        guard let target = target else { return }
        guard let build = build else { return }

        loadingIndicator?.startAnimating()

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
                    if self.loadingIndicator != nil && self.loadingIndicator!.isAnimating {
                        self.loadingIndicator!.stopAnimating()
                    }

                    logOutputView.text = existingText + textToAdd
                }
            }
        }
    }

    @IBAction func onJumpToBottomTapped() {
        guard let length = logOutputView?.text.characters.count else { return }
        logOutputView?.scrollRangeToVisible(NSMakeRange(0, length))
    }
}
