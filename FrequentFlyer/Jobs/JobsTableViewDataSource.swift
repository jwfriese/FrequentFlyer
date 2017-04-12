import RxSwift
import RxDataSources

struct JobGroupSection: SectionModelType {
    typealias Item = Job
    var items: [Item]

    init() {
        self.items = []
    }

    init(original: JobGroupSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class JobsTableViewDataSource: RxTableViewSectionedReloadDataSource<JobGroupSection> {
    var jobsService = JobsService()
    var elapsedTimePrinter = ElapsedTimePrinter()

    private var target: Target!
    private var pipeline: Pipeline!

    func setUp(withTarget target: Target, pipeline: Pipeline) {
        self.target = target
        self.pipeline = pipeline

        configureCell = { (dataSource: TableViewSectionedDataSource<JobGroupSection>, tableView: UITableView, indexPath: IndexPath, item: JobGroupSection.Item) in
            let job = item
            let cell = tableView.dequeueReusableCell(withIdentifier: JobsTableViewCell.cellReuseIdentifier, for: indexPath) as? JobsTableViewCell
            cell?.jobNameLabel?.text = job.name
            if let nextBuild = job.nextBuild {
                cell?.latestJobLastEventTimeLabel?.text = self.elapsedTimePrinter.printTime(since: TimeInterval(nextBuild.startTime))
                cell?.buildStatusBadge?.setUp(for: nextBuild.status)
            } else if let finishedBuild = job.finishedBuild {
                cell?.latestJobLastEventTimeLabel?.text = self.elapsedTimePrinter.printTime(since: TimeInterval(finishedBuild.endTime))
                cell?.buildStatusBadge?.setUp(for: finishedBuild.status)
            } else {
                cell?.latestJobLastEventTimeLabel?.text = "--"
                cell?.buildStatusBadge?.isHidden = true
            }

            return cell!
        }
    }

    func openJobsStream() -> Observable<[JobGroupSection]> {
        return jobsService
            .getJobs(forTarget: target, pipeline: pipeline)
            .map { jobs in
                var section = JobGroupSection()
                section.items = jobs
                return [section]
        }
    }
}
