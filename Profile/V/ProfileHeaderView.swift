import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    static let reuseIdentifier = String(describing: ProfileHeaderView.self)
}
