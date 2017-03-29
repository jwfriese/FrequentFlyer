import UIKit
import RxSwift
import RxCocoa

class JobsViewController: UIViewController {
    @IBOutlet weak var jobsTableView: UITableView?

    var jobsService = JobsService()

    var pipeline: Pipeline?
    var target: Target?

    let disposeBag = DisposeBag()

    class var storyboardIdentifier: String { get { return "Jobs" } }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pipeline = pipeline else { return }
        guard let target = target else { return }
        guard let jobsTableView = jobsTableView else { return }

        title = pipeline.name

        jobsService
            .getJobs(forTarget: target, pipeline: pipeline)
            .bindTo(
            jobsTableView
                .rx
                .items(cellIdentifier: JobsTableViewCell.cellReuseIdentifier, cellType: JobsTableViewCell.self)) {
                index, job, cell in
                    cell.jobNameLabel?.text = job.name
        }
            .disposed(by: disposeBag)
    }
}
