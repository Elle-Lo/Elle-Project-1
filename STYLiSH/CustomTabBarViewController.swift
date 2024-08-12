import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: CustomTabBarController / UITabBarControllerDelegate
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        updateTabBarBadge()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCartItemsUpdated), name: .cartItemsUpdated, object: nil)
    }
    
    @objc private func handleCartItemsUpdated() {
        updateTabBarBadge()
    }
    
    private func updateTabBarBadge() {
        StorageManager.shared.updateTabBarBadge(for: self)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)
        
        if selectedIndex == 3 {
            if !isFacebookLoggedIn() {
                showLoginScreen()
                return false
            }
        }
        return true
    }
    
    func showLoginScreen() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            
            let customTransitioningDelegate = CustomTransitioningDelegate()
            loginVC.transitioningDelegate = customTransitioningDelegate
            
            loginVC.modalPresentationStyle = .custom
            loginVC.preferredContentSize = CGSize(width: 393, height: 200)
            
            self.present(loginVC, animated: true, completion: nil)
        } else {
            print("Unable to instantiate LoginViewController")
        }
    }
    
    func isFacebookLoggedIn() -> Bool {
        return AccessToken.current != nil && !AccessToken.current!.isExpired
    }
}

