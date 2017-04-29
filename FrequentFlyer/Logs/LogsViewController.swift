import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var logOutputView: UITextView?
    @IBOutlet weak var jumpToBottomButton: RoundedButton?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var sseService = SSEService()
    var logsStylingParser = LogsStylingParser()

    var target: Target?
    var build: Build?

    private var messagesToAdd = [String]()
    private var logsUpdateTimer: Timer!

    class var storyboardIdentifier: String { get { return "Logs" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let logOutputView = self.logOutputView else { return }

        logOutputView.text = ""
        logOutputView.backgroundColor = Style.Colors.logsBackground
        logOutputView.textContainerInset = UIEdgeInsets(top: 32, left: 32, bottom: 0, right:32)
        logOutputView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logOutputView.font = Style.Fonts.bold(withSize: 14)

        loadingIndicator?.color = Style.Colors.lightLoadingIndicator
        loadingIndicator?.hidesWhenStopped = true

        jumpToBottomButton?.setUp(withTitleText: "v",
                                  titleFont: Style.Fonts.button,
                                  controlStateTitleColors: [.normal : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)],
                                  controlStateButtonColors: [.normal : Style.Colors.buttonNormal]
        )

        logsUpdateTimer = Timer(timeInterval: 0.05, repeats: true) { _ in
            if !self.messagesToAdd.isEmpty {
                logOutputView.text = logOutputView.text + self.messagesToAdd.remove(at: 0)
            }
        }

        RunLoop.main.add(logsUpdateTimer, forMode: .defaultRunLoopMode)
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
                let messageTexts = messages.map { message -> String in
                    return self.logsStylingParser.stripStylingCoding(originalString: message.payload)
                }

                self.messagesToAdd.append(messageTexts.joined(separator: "\n"))

                DispatchQueue.main.async {
                    if self.loadingIndicator != nil && self.loadingIndicator!.isAnimating {
                        self.loadingIndicator!.stopAnimating()
                    }
                }
            }
        }
    }

    @IBAction func onJumpToBottomTapped() {
        guard let length = logOutputView?.text.characters.count else { return }
        logOutputView?.scrollRangeToVisible(NSMakeRange(0, length))
    }
}
