import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var logOutputView: UITextView?
    @IBOutlet weak var jumpToBottomButton: RoundedButton?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var sseService = SSEService()
    var logsStylingParser = LogsStylingParser()
    var keychainWrapper = KeychainWrapper()

    var target: Target?
    var build: Build?

    private var messagesToAdd = [String]()
    private var logsUpdateTimer: Timer!

    class var storyboardIdentifier: String { get { return "Logs" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LogsViewController.setConcourseEntryAsRootPageSegueId {
            guard let concourseEntryViewController = segue.destination as? ConcourseEntryViewController else {
                return
            }

            concourseEntryViewController.userTextInputPageOperator = UserTextInputPageOperator()

            let authMethodsService = AuthMethodsService()
            authMethodsService.httpClient = HTTPClient()
            authMethodsService.authMethodsDataDeserializer = AuthMethodDataDeserializer()
            concourseEntryViewController.authMethodsService = authMethodsService

            let unauthenticatedTokenService = UnauthenticatedTokenService()
            unauthenticatedTokenService.httpClient = HTTPClient()
            unauthenticatedTokenService.tokenDataDeserializer = TokenDataDeserializer()
            concourseEntryViewController.unauthenticatedTokenService = unauthenticatedTokenService

            concourseEntryViewController.navigationItem.hidesBackButton = true
        }
    }

    func fetchLogs() {
        guard let target = target else { return }
        guard let build = build else { return }

        loadingIndicator?.startAnimating()

        let connection = sseService.openSSEConnection(target: target, build: build)
        connection.onLogsReceived = onMessagesReceived
        connection.onError = { _ in self.handleAuthorizationError() }
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
        guard let length = logOutputView?.text.count else { return }
        logOutputView?.scrollRangeToVisible(NSMakeRange(0, length))
    }

    private func handleAuthorizationError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Unauthorized",
                message: "Your credentials have expired. Please authenticate again.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "Log Out",
                    style: .destructive,
                    handler: { _ in
                        self.keychainWrapper.deleteTarget()
                        self.performSegue(withIdentifier: LogsViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
                }
                )
            )

            self.present(alert, animated: true, completion: nil)
            self.loadingIndicator?.stopAnimating()
        }
    }
}
