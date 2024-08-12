import UIKit
import TPDirect

// MARK: PaymentViewController
class PaymentViewController: UIViewController {
    
    @IBOutlet weak var paymentTableView: UITableView!
    
    let header = ["結帳商品", "收件資訊", "付款詳情"]
    
    var isUserInfoValid = false
    var cartItems: [CartItem] = []
    var userData: (name: String, email: String, phone: String, address: String, shipTime: String) = ("", "", "", "", "")
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentTableView.dataSource = self
        paymentTableView.delegate = self
        loadCartItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCart), name: .didUpdateCart, object: nil)
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back02"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        
        paymentTableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)
        paymentTableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)
        paymentTableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)
        
        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)
        paymentTableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))
    }
    
    override func viewWillAppear( _ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func loadCartItems() {
        cartItems = StorageManager.shared.fetchCartItems()
        paymentTableView.reloadData()
    }
    
    @objc private func updateCart() {
        loadCartItems()
    }
    
    private func calculateTotal() -> (totalPrice: Int, productCount: Int) {
        var totalPrice = 0
        var productCount = 0
        
        for item in cartItems {
            if let price = Int(item.price ?? "0"), let quantity = Int(item.quantity ?? "0") {
                totalPrice += price * quantity
                productCount += quantity
            }
        }
        return (totalPrice, productCount)
    }
    
    func updateCheckoutButtonState() {
        guard let paymentCell = paymentTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? STPaymentInfoTableViewCell else { return }
        paymentCell.isUserInfoValid = isUserInfoValid
        paymentCell.updateCheckoutButtonState()
    }
}

// MARK: UITableView
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }
        
        headerView.titleLabel.text = header[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? cartItems.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "STOrderProductCell", for: indexPath) as? STOrderProductCell else {
                return UITableViewCell()
            }
            let cartItems = StorageManager.shared.fetchCartItems()
            let item = cartItems[indexPath.row]
            cell.configure(with: item)
            return cell
            
        } else if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "STOrderUserInputCell", for: indexPath) as? STOrderUserInputCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.nameTextField.text = userData.name
            cell.emailTextField.text = userData.email
            cell.phoneTextField.text = userData.phone
            cell.addressTextField.text = userData.address
            cell.shipTimeSelector.selectedSegmentIndex = Int(userData.shipTime) ?? 0
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "STPaymentInfoTableViewCell", for: indexPath) as? STPaymentInfoTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            let (totalPrice, productCount) = calculateTotal()
            let shippingPrice = 60
            cell.layoutCellWith(productPrice: totalPrice, shipPrice: shippingPrice, productCount: productCount)
            return cell
        }
    }
}

// MARK: STPaymentInfoTableViewCellDelegate / STOrderUserInputCellDelegate
extension PaymentViewController: STPaymentInfoTableViewCellDelegate, STOrderUserInputCellDelegate  {
    func presentSuccessViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let successVC = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as? SuccessViewController {
            self.navigationController?.pushViewController(successVC, animated: true)
        }
    }
    
    func didUpdateUserInfoValidStatus(_ isValid: Bool) {
        isUserInfoValid = isValid
        updateCheckoutButtonState()
    }
    
    func didChangeUserData(_ cell: STOrderUserInputCell, username: String, email: String, phoneNumber: String, address: String, shipTime: String) {
        userData = (username, email, phoneNumber, address, shipTime)
        
        if !userData.name.isEmpty && !userData.email.isEmpty && !userData.phone.isEmpty && userData.phone.isNumber && !userData.address.isEmpty {
            isUserInfoValid = true
        } else {
            isUserInfoValid = false
        }
        
        updateCheckoutButtonState()
    }
    
    func didChangePaymentData(_ cell: STPaymentInfoTableViewCell, payment: String, cardNumber: String, dueDate: String, verifyCode: String) {
        print(payment, cardNumber, dueDate, verifyCode)
    }
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell) {
        paymentTableView.reloadData()
        updateCheckoutButtonState()
    }
    
    func checkout(_ cell:STPaymentInfoTableViewCell) {
    }
}

