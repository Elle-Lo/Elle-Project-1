import UIKit
import Foundation
import Kingfisher

class WomenClothesCell: UICollectionViewCell {
    
    @IBOutlet weak var womenProductImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "NT$\(product.price)"
        womenProductImage.kf.setImage(with: URL(string: product.mainImage), placeholder: UIImage(named: "Image_Placeholder"))
    }
}


