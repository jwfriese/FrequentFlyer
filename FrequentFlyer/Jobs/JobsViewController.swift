import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class JobsViewController: UIViewController {
    @IBOutlet weak var jobsTableView: UITableView?

    var jobsTableViewDataSource = JobsTableViewDataSource()

    var pipeline: Pipeline?
    var target: Target?

    let disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "Jobs" } }
    class var showJobDetailSegueId: String { get { return "ShowJobDetail" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        guard let pipeline = pipeline else { return }
        guard let target = target else { return }

        title = pipeline.name

        setUpCellPopulation(withTarget: target, pipeline: pipeline)
        setUpCellSelect()
    }

    private func setUpCellPopulation(withTarget target: Target, pipeline: Pipeline) {
        guard let jobsTableView = jobsTableView else { return }

        jobsTableViewDataSource.setUp(withTarget: target, pipeline: pipeline)
        jobsTableViewDataSource.openJobsStream()
            .bind(to: jobsTableView.rx.items(dataSource: jobsTableViewDataSource))
            .disposed(by: disposeBag)
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
            .addDisposableTo(disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == JobsViewController.showJobDetailSegueId {
            guard let jobDetailViewController = segue.destination as? JobDetailViewController else {
                return
            }

            jobDetailViewController.target = target
            jobDetailViewController.pipeline = pipeline
            jobDetailViewController.job = sender as? Job
        }
    }
}
