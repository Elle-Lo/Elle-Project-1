import UIKit
import Foundation

// MARK: CategoryViewController
class CategoryViewController: UIViewController {
    
    @IBOutlet weak var womenClothesButton: UIButton!
    @IBOutlet weak var menClothesButton: UIButton!
    @IBOutlet weak var accessoriesButton: UIButton!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewTopConstraint: NSLayoutConstraint!
    
    
    var width: CGFloat?
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        width = view.bounds.width
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        
        womenClothesButton.setTitleColor(.green, for: .normal)
        let buttons = buttonStackView.subviews
        for (index,button) in buttons.enumerated() {
            let uibutton = button as! UIButton
            uibutton.tag = index
            uibutton.addTarget(self, action: #selector(changePage), for: .touchUpInside)
            womenClothesButton.tintColor = .black
            menClothesButton.tintColor = .gray
            accessoriesButton.tintColor = .gray
        }
    }
    
    @objc func changePage(sender: UIButton){
        setButtonConstraint(button: sender)
        let targetX = CGFloat(sender.tag) * width!
        scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        updateButtonColors(selectedButton: sender)
    }
    
    func updateButtonColors(selectedButton: UIButton) {
            let buttons = buttonStackView.subviews
            for button in buttons {
                let uibutton = button as! UIButton
                if uibutton == selectedButton {
                    uibutton.tintColor = .black
                } else {
                    uibutton.tintColor = .gray
                }
            }
        }
    
}

// MARK: ScrollViewDelegate
extension CategoryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let width = width else { return }
            
            let offset = scrollView.contentOffset.x / width
            let buttonIndex = Int(round(offset))
            let buttons = buttonStackView.subviews
            let selectedButton = buttons[buttonIndex] as! UIButton
            
            setButtonConstraint(button: selectedButton)
        }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let width = width else { return }
        
        let currentPage = Int(targetContentOffset.pointee.x / width)
        let buttons = buttonStackView.subviews
        let uibutton = buttons[currentPage] as! UIButton
        setButtonConstraint(button: uibutton)
        updateButtonColors(selectedButton: uibutton)
    }
    
    func setButtonConstraint(button: UIButton){
        
        underlineViewWidthConstraint.isActive = false
        underlineViewCenterXConstraint.isActive = false
        underlineViewTopConstraint.isActive = false
        
        underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: button.widthAnchor)
        underlineViewCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: button.bottomAnchor)
        
        underlineViewWidthConstraint.isActive = true
        underlineViewCenterXConstraint.isActive = true
        underlineViewTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.23, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
