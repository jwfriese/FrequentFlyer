import RxSwift
import RxDataSources

class PublicPipelinesTableViewDataSource: RxTableViewSectionedReloadDataSource<PipelineGroupSection>, UITableViewDelegate {

    func setUp() {
        configureCell = { (dataSource: TableViewSectionedDataSource<PipelineGroupSection>, tableView: UITableView, indexPath: IndexPath, item: PipelineGroupSection.Item) in
            let pipeline = item
            let cell = tableView.dequeueReusableCell(withIdentifier: PipelineTableViewCell.cellReuseIdentifier, for: indexPath) as! PipelineTableViewCell
            cell.nameLabel?.text = pipeline.name

            return cell
        }

        titleForHeaderInSection = { (dataSource: TableViewSectionedDataSource<PipelineGroupSection>, sectionIndex: Int) -> String in
            let section = dataSource[sectionIndex]
            if let teamName = section.items.first?.teamName {
                return teamName
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
