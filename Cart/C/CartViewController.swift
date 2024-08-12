import UIKit
import Foundation
import FBSDKLoginKit
import FacebookCore

// MARK: Notification.Name
extension Notification.Name {
    static let didUpdateCart = Notification.Name("didUpdateCart")
    static let cartItemsUpdated = Notification.Name("cartItemsUpdated")
}

// MARK: CartViewController
class CartViewController: UIViewController {
    
    var cartItems: [CartItem] = []
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var goToCartButton: UIButton!
    
    @IBAction func goToCartButton(_ sender: UIButton) {
        if StorageManager.shared.fetchCartItems().isEmpty {
            goToCartButton.isEnabled = false
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTableView.dataSource = self
        loadCartItems()
        updateCartButtonState()
        setupLogoutButton()
        NotificationCenter.default.addObserver(self, selector: #selector(cartItemsUpdated), name: .cartItemsUpdated, object: nil)
        cartItems = StorageManager.shared.fetchCartItems()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCart), name: .didUpdateCart, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cartItems = StorageManager.shared.fetchCartItems()
        cartTableView.reloadData()
    }
    
    @objc private func cartItemsUpdated() {
        cartItems = StorageManager.shared.fetchCartItems()
        cartTableView.reloadData()
    }
    
    
    private func setupLogoutButton() {
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.setTitleColor(.lightGray, for: .normal)
        
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.borderColor = UIColor.lightGray.cgColor
        logoutButton.layer.borderWidth = 1.5
        logoutButton.clipsToBounds = true
        
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        logoutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)

        let logoutBarButtonItem = UIBarButtonItem(customView: logoutButton)
        self.navigationItem.rightBarButtonItem = logoutBarButtonItem
    }
    
    @objc private func logOutButtonTapped() {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        print("User logged out from Facebook")
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func loadCartItems() {
        cartItems = StorageManager.shared.fetchCartItems()
        cartTableView.reloadData()
        updateCartButtonState()
    }
    
    private func updateCartButtonState() {
        goToCartButton.isEnabled = !cartItems.isEmpty
        goToCartButton.backgroundColor = cartItems.isEmpty ? UIColor.lightGray : UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
    }
    
    func deleteCartItem(at indexPath: IndexPath) {
        let cartItem = cartItems[indexPath.row]
        StorageManager.shared.deleteCartItem(cartItem: cartItem)
        loadCartItems()
    }
    
    @objc private func updateCart() {
        loadCartItems()
    }
}

// MARK: UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartPageCell", for: indexPath) as? CartPageCell else {
            return UITableViewCell()
        }
        let cartItems = StorageManager.shared.fetchCartItems()
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
}

// MARK: CartPageCellDelegate
extension CartViewController: CartPageCellDelegate {
    
    func didRemoveItem(_ cell: CartPageCell) {
        if let indexPath = cartTableView.indexPath(for: cell) {
            
            cartItems = StorageManager.shared.fetchCartItems()
            
            guard indexPath.row < cartItems.count else {
                print("Invalid index path")
                return
            }
            
            let item = cartItems[indexPath.row]
            StorageManager.shared.deleteCartItem(cartItem: item)
            cartItems.remove(at: indexPath.row)
            
            cartTableView.deleteRows(at: [indexPath], with: .automatic)
            updateCartButtonState()
        }
    }
    
    func didUpdateQuantity(_ cell: CartPageCell, quantity: Int) {
        if let indexPath = cartTableView.indexPath(for: cell) {
            cartItems = StorageManager.shared.fetchCartItems()
            
            guard indexPath.row < cartItems.count else {
                print("Invalid index path")
                return
            }
            
            let item = cartItems[indexPath.row]
            StorageManager.shared.updateCartItemQuantity(cartItem: item, quantity: "\(quantity)")
            cartItems[indexPath.row] = item
            cartTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
