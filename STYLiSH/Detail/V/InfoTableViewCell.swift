import UIKit
import Foundation


// MARK: InfoTableViewCell
class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNumberLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorImage1: UIImageView!
    @IBOutlet weak var colorImage2: UIImageView!
    @IBOutlet weak var colorImage3: UIImageView!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var textureLabel: UILabel!
    @IBOutlet weak var washLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    func configure(with product: Product) {
        productNameLabel.text = product.title
        priceLabel.text = "NT$\(product.price)"
        productNumberLabel.text = "\(product.id)"
        descriptionLabel.text = product.story
        
        colorLabel.text = "顏色  |  "
        let colorImages = [colorImage1, colorImage2, colorImage3]
        for (index, color) in product.colors.prefix(3).enumerated() {
            if let uiColor = UIColor(hex: color.code) {
                colorImages[index]?.backgroundColor = uiColor
                colorImages[index]?.layer.borderColor = UIColor.black.cgColor
                colorImages[index]?.layer.borderWidth = 0.5
            }
        }
        if product.sizes.isEmpty {
            sizeLabel.text = "尺寸  |  無法顯示"
        } else if product.sizes.count == 1 {
            sizeLabel.text = "尺寸  |  \(product.sizes[0])"
        } else {
            if let minSize = product.sizes.first, let maxSize = product.sizes.last {
                sizeLabel.text = "尺寸  |  \(minSize) - \(maxSize)"
            }
        }
        
        amountLabel.text = "庫存  |  \(product.variants.reduce(0) { $0 + $1.stock })"
        textureLabel.text = "材質  |  \(product.texture)"
        washLabel.text = "洗滌  |  \(product.wash)"
        originLabel.text = "產地  |  \(product.place)"
        noteLabel.text = "備註  |  \(product.note)"
        
    }
}
