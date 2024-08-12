import UIKit
import Foundation

class SuccessViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func goBackShoppingButton(_ sender: UIButton) {
        StorageManager.shared.clearCart()
     
        if let cartVC = navigationController?.viewControllers.first(where: { $0 is CartViewController }) {
            navigationController?.popToViewController(cartVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
}

