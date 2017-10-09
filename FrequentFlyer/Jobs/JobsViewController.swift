import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class JobsViewController: UIViewController {
    @IBOutlet weak var jobsTableView: UITableView?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?

    var jobsTableViewDataSource = JobsTableViewDataSource()
    var keychainWrapper = KeychainWrapper()

    var pipeline: Pipeline?
    var target: Target?
    var dataStream: JobsDataStream?

    let disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "Jobs" } }
    class var showJobDetailSegueId: String { get { return "ShowJobDetail" } }
    class var setConcourseEntryAsRootPageSegueId: String { get { return "SetConcourseEntryAsRootPage" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        guard let pipeline = pipeline else { return }

        title = pipeline.name

        if !pipeline.isPublic {
            setUpCellSelect()
        }
        setUpCellPopulation(withPipeline: pipeline)
    }

    private func setUpCellSelect() {
        guard let jobsTableView = jobsTableView else { return }

        jobsTableView
            .rx
            .modelSelected(Job.self)
            .subscribe(onNext: { job in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: JobsViewController.showJobDetailSegueId, sender: job)
                }
            },
                       onError: nil,
                       onCompleted: nil,
                       onDisposed: nil
            )
            .disposed(by: disposeBag)
    }

    private func setUpCellPopulation(withPipeline pipeline: Pipeline) {
        guard let jobsTableView = jobsTableView else { return }
        guard let dataStream = dataStream else { return }

        jobsTableView.separatorStyle = .none
        loadingIndicator?.startAnimating()

        jobsTableViewDataSource.setUp()
        dataStream.open(forPipeline: pipeline)
            .do(onNext: self.onSuccess(),
                onError: self.onError()
            )
            .bind(to: jobsTableView.rx.items(dataSource: jobsTableViewDataSource))
            .disposed(by: disposeBag)

        jobsTableView.rx.setDelegate(jobsTableViewDataSource)
            .disposed(by: disposeBag)
    }

    private func onSuccess() -> ([JobGroupSection]) -> () {
        return { _ in
            DispatchQueue.main.async {
                self.jobsTableView?.separatorStyle = .singleLine
                self.loadingIndicator?.stopAnimating()
            }
        }
    }

    private func onError() -> (Error) -> () {
        return { error in
            if error is AuthorizationError {
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
                            self.performSegue(withIdentifier: JobsViewController.setConcourseEntryAsRootPageSegueId, sender: nil)
                    }
                    )
                )

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                    self.jobsTableView?.separatorStyle = .singleLine
                    self.loadingIndicator?.stopAnimating()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == JobsViewController.showJobDetailSegueId {
            guard let jobDetailViewController = segue.destination as? JobDetailViewController else { return }
            guard let target = target else { return }

            jobDetailViewController.target = target
            jobDetailViewController.pipeline = pipeline
            jobDetailViewController.job = sender as? Job
        }
    }
}
