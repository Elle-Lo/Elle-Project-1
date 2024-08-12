import UIKit
import Foundation

// MARK: Protocol: AddToCartViewControllerDelegate 
protocol AddToCartViewControllerDelegate: AnyObject {
    func didTapBackButton()
    func didUpdateSelection(status: Bool)
    func collectSelectedInfo(selectColor: String?, selectSize: String?, currentQty: String?, selectStock: String?)
}

// MARK: AddToCartViewController
class AddToCartViewController: UIViewController {
    
    @IBOutlet weak var addToCartTableView: UITableView!
    @IBAction func backButton(_ sender: UIButton) {
        self.delegate?.didTapBackButton()
        self.dismiss(animated: false, completion: nil)
    }
    
    var product: Product?
    var selectSize: String?
    var selectColor: String?
    var currentQty: String?
    var selectStock: String?
    weak var delegate: AddToCartViewControllerDelegate?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addToCartTableView.dataSource = self
        addToCartTableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension AddToCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCartCell", for: indexPath) as? AddToCartCell else {
            return UITableViewCell()
        }
        if let product = product {
            cell.configure(with: product)
        }
        cell.delegate = self
        return cell
    }
}

// MARK: AddToCartCellDelegate
extension AddToCartViewController: AddToCartCellDelegate {
    func collectSelectedInfo(selectColor: String?, selectSize: String?, currentQty: String?, selectStock: String?) {
        delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
    }
    
    func didUpdateSelection(status: Bool) {
        delegate?.didUpdateSelection(status: status)
    }
}
