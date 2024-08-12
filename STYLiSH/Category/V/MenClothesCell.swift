import UIKit
import Foundation
import Kingfisher

class MenClothesCell: UICollectionViewCell {
    
    @IBOutlet weak var menProductImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
 
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "NT$\(product.price)"
        menProductImage.kf.setImage(with: URL(string: product.mainImage), placeholder: UIImage(named: "Image_Placeholder"))
    }
}
