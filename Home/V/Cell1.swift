import UIKit
import Kingfisher

class Cell1: UITableViewCell {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemThickness: UILabel!
    @IBOutlet var itemElasticity: UILabel!
    @IBOutlet var itemImage: UIImageView!
    
    private let placeholderImage = UIImage(named: "Image_Placeholder")
    
}

extension Cell1: ConfigurableCell {
    
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
        
        if let url = URL(string: product.mainImage) {
            itemImage.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            itemImage.image = placeholderImage
        }
    }
}


