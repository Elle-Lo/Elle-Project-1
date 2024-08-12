import UIKit
import Kingfisher
import MJRefresh
import CoreData

// MARK: HomeViewController
class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    let tableView = UITableView()
    var marketManager = MarketManager()
    var sections: [MarketingSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marketManager.delegate = self
        marketManager.getMarketingHots()
        homeTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
    }
    
    @objc func refreshData() {
        marketManager.getMarketingHots()
        homeTableView.mj_header?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowHomeDetailSegue",
               let detailVC = segue.destination as? DetailViewController,
               let product = sender as? Product {
                detailVC.product = product
            }
        }
}

// MARK: MarketManagerDelegate
extension HomeViewController: MarketManagerDelegate {
    
    func manager(_ manager: MarketManager, didGet marketingHots: [MarketingSection]) {
        self.sections = marketingHots
        homeTableView.reloadData()
        homeTableView.mj_header?.endRefreshing()
    }
    
    func manager(_ manager: MarketManager, didFailWith error: Error) {
        print("Error: \(error.localizedDescription)")
        homeTableView.mj_header?.endRefreshing()
    }
}

// MARK: TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].products.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let product = section.products[indexPath.row]
        
        let cell: UITableViewCell
        
        if indexPath.row % 2 == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        }
        
        if let configurableCell = cell as? ConfigurableCell {
            configurableCell.configure(with: product)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        headerView.titleLabel.text = sections[section].title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let selectedProduct = sections[indexPath.section].products[indexPath.row]
            performSegue(withIdentifier: "ShowHomeDetailSegue", sender: selectedProduct)
        }
    
}





