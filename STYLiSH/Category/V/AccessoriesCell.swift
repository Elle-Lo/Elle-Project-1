import UIKit
import Foundation
import Kingfisher

class AccessoriesCell: UICollectionViewCell {
    
    @IBOutlet weak var accessoriesImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "NT$\(product.price)"
        accessoriesImage.kf.setImage(with: URL(string: product.mainImage), placeholder: UIImage(named: "Image_Placeholder"))
    }
}
