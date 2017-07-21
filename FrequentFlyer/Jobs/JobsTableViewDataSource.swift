import RxSwift
import RxDataSources

class JobsTableViewDataSource: RxTableViewSectionedReloadDataSource<JobGroupSection>, UITableViewDelegate {
    var jobsService = JobsService()
    var elapsedTimePrinter = ElapsedTimePrinter()

    func setUp() {
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

        titleForHeaderInSection = { (dataSource: TableViewSectionedDataSource<JobGroupSection>, sectionIndex: Int) -> String in
            let section = dataSource[sectionIndex]
            if let groupName = section.items.first?.groups.first {
                return groupName
            }

            return "ungrouped"
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = Style.Colors.logsBackground
            headerView.textLabel?.font = Style.Fonts.regular(withSize: 18)
            headerView.textLabel?.textColor = UIColor.white
        }
    }
}
