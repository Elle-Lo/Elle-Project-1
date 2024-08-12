import UIKit

// MARK: STOrderProductCell
class STOrderProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var productSizeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var item: CartItem?
    
    func configure(with item: CartItem) {
        self.item = item
        productTitleLabel.text = item.name
        productSizeLabel.text = item.size
        priceLabel.text = "NT$\(item.price ?? "0")"
        orderNumberLabel.text = item.quantity
        
        if let color = UIColor(hex: item.color ?? "nil") {
            colorView.backgroundColor = color
        }
        
        if let url = URL(string: item.image ?? "nil") {
            productImageView.kf.setImage(with: url, placeholder: UIImage(named: "Image_Placeholder"), options: [.cacheOriginalImage]) { result in
                switch result {
                case .success(let value):
                    print("Image: \(value.image); Image URL: \(value.source.url?.absoluteString ?? "none")")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
