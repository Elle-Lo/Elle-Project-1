import UIKit
import Foundation


// MARK: HeaderView
class HeaderView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        titleLabel.frame = CGRect(x: 16, y: 0, width: frame.size.width - 32, height: frame.size.height - 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: HonePageDataModel
struct Hots: Codable {
    let data: [MarketingSection]
}

struct MarketingSection: Codable {
    let title: String
    let products: [Product]
}
