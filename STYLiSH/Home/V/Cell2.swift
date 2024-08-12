import UIKit
import Kingfisher

class Cell2: UITableViewCell {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemThickness: UILabel!
    @IBOutlet var itemElasticity: UILabel!
    @IBOutlet var itemImage1: UIImageView!
    @IBOutlet var itemImage2: UIImageView!
    @IBOutlet var itemImage3: UIImageView!
    @IBOutlet var itemImage4: UIImageView!
    
    private let placeholderImage = UIImage(named: "Image_Placeholder")
    
}

extension Cell2: ConfigurableCell {
    
    func configure(with product: Product) {
        itemName.text = product.title
        
        let descriptionComponents = product.description.components(separatedBy: "\r\n")
        if descriptionComponents.count > 0 {
            itemThickness.text = descriptionComponents[0]
        } else {
            itemThickness.text = "未知"
        }
        if descriptionComponents.count > 1 {
            itemElasticity.text = descriptionComponents[1]
        } else {
            itemElasticity.text = "未知"
        }
        
        let imageViews = [itemImage1, itemImage2, itemImage3, itemImage4]
        
        imageViews.forEach { imageView in
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
        }
        
        for (index, imageUrl) in product.images.prefix(4).enumerated() {
            if let url = URL(string: imageUrl) {
                imageViews[index]?.kf.setImage(with: url, placeholder: placeholderImage)
            } else {
                imageViews[index]?.image = placeholderImage
            }
        }
    }
}
