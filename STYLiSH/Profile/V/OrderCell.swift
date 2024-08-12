import UIKit

class OrderCell: UICollectionViewCell {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configure(with data: CellData) {
            imageView.image = UIImage(named: data.imageName)
            label.text = data.text
        }
}
