import UIKit

class TargetListViewController: UIViewController {
    @IBOutlet weak var targetListTableView: UITableView?
    
    var targetListService: TargetListService?
    
    var targetList: [Target]?
    
    class var storyboardIdentifier: String {
        get {
            return "TargetList"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let targetListService = targetListService else { return }
        
        targetListTableView?.dataSource = self
        targetList = targetListService.getTargetList()
        
        title = "Targets"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddTarget" {
            if let addTargetViewController = segue.destinationViewController as? AddTargetViewController {
                addTargetViewController.addTargetDelegate = self
                
                let tokenAuthService = TokenAuthService()
                tokenAuthService.httpClient = HTTPClient()
                tokenAuthService.tokenDataDeserializer = TokenDataDeserializer()
                addTargetViewController.tokenAuthService = tokenAuthService
            }
        }
    }
}

extension TargetListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let targetList = targetList else { return 0 }
        return targetList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TargetListTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! TargetListTableViewCell
        cell.targetNameLabel?.text = targetList![indexPath.row].name
        
        return cell
    }
}

extension TargetListViewController: AddTargetDelegate {
    func onTargetAdded(target: Target) {
        targetList?.append(target)
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.popViewControllerAnimated(true)
            self.targetListTableView?.reloadData()
        }
    }
}