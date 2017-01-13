import UIKit
import RxSwift

class AuthMethodListViewController: UIViewController {
    @IBOutlet weak var authMethodListTableView: UITableView!
    
    var authMethodStream: Observable<AuthMethod>!
    var concourseURLString: String?
    
    class var storyboardIdentifier: String { get { return "AuthMethodList" } }
    class var showBasicUserAuthSegueId: String { get { return "ShowBasicUserAuth" } }
    class var showGithubAuthSegueId: String { get { return "ShowGithubAuth" } }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        
        authMethodListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        authMethodStream.toArray()
            .bindTo(authMethodListTableView.rx.items(cellIdentifier: "DefaultCell")) { (_, authMethod, cell) in
                switch authMethod.type {
                case .basic:
                    cell.textLabel?.text = "Basic"
                case .github:
                    cell.textLabel?.text = "Github"
                }}
            .addDisposableTo(self.disposeBag)
        
        authMethodListTableView.rx.modelSelected(AuthMethod.self)
            .subscribe(onNext: { authMethod in
                switch authMethod.type {
                case .basic:
                    self.performSegue(withIdentifier: AuthMethodListViewController.showBasicUserAuthSegueId, sender: nil)
                case .github:
                    self.performSegue(withIdentifier: AuthMethodListViewController.showGithubAuthSegueId, sender: authMethod.url)
                }})
            .addDisposableTo(self.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthMethodListViewController.showBasicUserAuthSegueId {
            guard let basicUserAuthViewController = segue.destination as? BasicUserAuthViewController else {
                return
            }
            
            guard let concourseURLString = concourseURLString else { return }
            basicUserAuthViewController.concourseURLString = concourseURLString
            basicUserAuthViewController.keychainWrapper = KeychainWrapper()
            
            let basicAuthTokenService = BasicAuthTokenService()
            basicAuthTokenService.httpClient = HTTPClient()
            basicAuthTokenService.tokenDataDeserializer = TokenDataDeserializer()
            basicUserAuthViewController.basicAuthTokenService = basicAuthTokenService
        } else if segue.identifier == AuthMethodListViewController.showGithubAuthSegueId {
            guard let githubAuthViewController = segue.destination as? GithubAuthViewController else {
                return
            }
            
            guard let githubAuthURLString = sender as? String else { return }
            githubAuthViewController.githubAuthURLString = githubAuthURLString
            
            guard let concourseURLString = concourseURLString else { return }
            githubAuthViewController.concourseURLString = concourseURLString
            
            githubAuthViewController.keychainWrapper = KeychainWrapper()
            githubAuthViewController.httpSessionUtils = HTTPSessionUtils()
            
            let tokenValidationService = TokenValidationService()
            tokenValidationService.httpClient = HTTPClient()
            githubAuthViewController.tokenValidationService = tokenValidationService
            
            githubAuthViewController.userTextInputPageOperator = UserTextInputPageOperator()
        }
    }
}
