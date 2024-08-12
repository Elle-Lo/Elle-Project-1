import UIKit
import Foundation
import MBProgressHUD
import IQKeyboardManagerSwift

// MARK: DetailViewController
class DetailViewController: UIViewController {
    
    @IBOutlet weak var addToCartContainerView: UIView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var detailTableView: UITableView! {
        didSet {
            self.detailTableView.rowHeight = UITableView.automaticDimension
            self.detailTableView.estimatedRowHeight = 500
            detailTableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    var status: Bool = true
    var product: Product?
    var selectedItemName: String?
    var selectedItemPrice: String?
    var selectedItemImage: String?
    var selectedColor: String?
    var selectedSize: String?
    var selectedQuantity: String?
    var selectedStock: String?
    
    @IBAction func addToCartButton(_ sender: UIButton) {
        if addToCartContainerView.isHidden {
            showAddToCartView()
        } else {
            if status {
                addToCartButton.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
                addToCartButton.titleLabel?.textColor = .white
                
                if let product = product {
                    selectedItemName = product.title
                    selectedItemImage = product.mainImage
                    selectedItemPrice = "\(product.price)"
                }
                StorageManager.shared.saveCartItem(
                    name: selectedItemName,
                    color: selectedColor,
                    size: selectedSize,
                    quantity: selectedQuantity,
                    image: selectedItemImage,
                    price: selectedItemPrice,
                    stock: selectedStock
                )
                NotificationCenter.default.post(name: .didUpdateCart, object: nil)
                
                didAddToCartSuccessfully()
                hideAddToCartView()
                addToCartButton.isEnabled = true
            } else {
                addToCartButton.isEnabled = false
            }
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        setupAddToCartView()
        setupOverlayView()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back01"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK: Pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddToCartDetail" {
            if let cartVC = segue.destination as? AddToCartViewController {
                cartVC.delegate = self
                cartVC.product = product
                cartVC.selectColor = selectedColor
                cartVC.selectSize = selectedSize
                cartVC.currentQty = selectedQuantity
            }
        }
    }
    
    // MARK: Settings & Function
    private var overlayView: UIView!
    private func setupOverlayView() {
        overlayView = UIView(frame: detailTableView.frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isHidden = true
        view.insertSubview(overlayView, aboveSubview: detailTableView)
    }
    
    private func setupAddToCartView() {
        addToCartContainerView.transform = CGAffineTransform(translationX: 0, y: addToCartContainerView.frame.height)
        view.layoutIfNeeded()
        addToCartContainerView.layer.cornerRadius = 15
        addToCartContainerView.layer.masksToBounds = true
        addToCartContainerView.isHidden = true
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showAddToCartView() {
        overlayView.isHidden = false
        addToCartContainerView.isHidden = false
        addToCartContainerView.transform = CGAffineTransform(translationX: 0, y: addToCartContainerView.frame.height)
        UIView.animate(withDuration: 0.2) {
            self.addToCartContainerView.transform = .identity
        }
        addToCartButton.isEnabled = false
        addToCartButton.backgroundColor = .lightGray
        addToCartButton.titleLabel?.textColor = .white
    }

    private func hideAddToCartView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.addToCartContainerView.transform = CGAffineTransform(translationX: 0, y: self.addToCartContainerView.frame.height)
        }) { _ in
            self.addToCartContainerView.isHidden = true
            self.overlayView.isHidden = true
        }
        addToCartButton.isEnabled = true
    }
    
    func didAddToCartSuccessfully() {
        addToCartButton.isEnabled = true
        hideAddToCartView()
        showSuccessAnimation()
        resetSelections()
    }
    
    func resetSelections() {
        selectedColor = nil
        selectedSize = nil
        selectedQuantity = "1"
        status = false
    }
    
    func showSuccessAnimation() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .customView
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .black
        hud.customView = UIImageView(image: UIImage(named: "Success01"))
        hud.label.text = "success"
        hud.label.textColor = .white
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    private func updateAddToCartButtonState() {
        if status {
            addToCartButton.isEnabled = true
            addToCartButton.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
        } else {
            addToCartButton.isEnabled = false
            addToCartButton.backgroundColor = .lightGray
        }
    }
    
}

// MARK: TableView
extension DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = product else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: product)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as? InfoTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: product)
            return cell
        }
    }
    
}

// MARK: UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

// MARK: AddToCartViewControllerDelegate
extension DetailViewController: AddToCartViewControllerDelegate {
    func collectSelectedInfo(selectColor: String?, selectSize: String?, currentQty: String?, selectStock: String?) {
        self.selectedColor = selectColor
        self.selectedSize = selectSize
        self.selectedQuantity = currentQty
        self.selectedStock = selectStock
    }
    
    func didTapBackButton() {
        hideAddToCartView()
        addToCartButton.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
        addToCartButton.titleLabel?.textColor = .white
    }
    
    func didUpdateSelection(status: Bool) {
        self.status = status
        updateAddToCartButtonState()
    }
}
