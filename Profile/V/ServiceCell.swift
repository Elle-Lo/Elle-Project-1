import UIKit

class ServiceCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with data: CellData) {
        imageView.image = UIImage(named: data.imageName)
        label.text = data.text
    }
}
