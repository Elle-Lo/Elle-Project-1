import UIKit
import Foundation
import Kingfisher

// MARK: Protocol CartPageCellDelegate
protocol CartPageCellDelegate: AnyObject {
    func didRemoveItem(_ cell: CartPageCell)
    func didUpdateQuantity(_ cell: CartPageCell, quantity: Int)
}

// MARK: CartPageCell
class CartPageCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var subtractButton: UIButton! {
        didSet {
            subtractButton.layer.borderColor = UIColor.lightGray.cgColor
            subtractButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.borderColor = UIColor.black.cgColor
            addButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.layer.borderColor = UIColor.black.cgColor
            textField.layer.borderWidth = 1
            
            textField.isEnabled = true
            textField.delegate = self
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @IBAction func tapSubtractButton(_ sender: UIButton) {
        if let currentText = textField.text, let currentQuantity = Int(currentText), currentQuantity > 1 {
            quantity = currentQuantity - 1
            textField.text = "\(quantity)"
            updateButtonStates()
            delegate?.didUpdateQuantity(self, quantity: quantity)
        }
    }
    @IBAction func tapAddButton(_ sender: UIButton) {
        if let currentText = textField.text, let currentQuantity = Int(currentText), currentQuantity < maxQuantity {
            quantity = currentQuantity + 1
            textField.text = "\(quantity)"
            updateButtonStates()
            delegate?.didUpdateQuantity(self, quantity: quantity)
        }
    }
    @IBAction func removeButton(_ sender: UIButton) {
        guard let item = item else {
            return
        }
        delegate?.didRemoveItem(self)
        StorageManager.shared.deleteCartItem(cartItem: item)
    }
    
    weak var delegate: CartPageCellDelegate?
    var item: CartItem?
    var quantity: Int = 1
    var maxQuantity: Int = 1
    
    // MARK: awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.text = "\(quantity)"
        textField.textAlignment = .center
        updateButtonStates()
    }
    
    func configure(with item: CartItem) {
        self.item = item
        productNameLabel.text = item.name
        sizeLabel.text = item.size
        priceLabel.text = "NT$\(item.price ?? "0")"
        textField.text = item.quantity
        
        if let color = UIColor(hex: item.color ?? "nil") {
            colorImage.backgroundColor = color
        }
        
        if let url = URL(string: item.image ?? "nil") {
            productImage.kf.setImage(with: url, placeholder: UIImage(named: "Image_Placeholder"), options: [.cacheOriginalImage]) { result in
                switch result {
                case .success(let value):
                    print("Image: \(value.image); Image URL: \(value.source.url?.absoluteString ?? "none")")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        if let stock = item.stock, let maxStock = Int(stock) {
            maxQuantity = maxStock
        }
        updateButtonStates()
    }
    
    // MARK: Border settings
    func subtractButtonBorderActivate() {
        subtractButton.layer.borderColor = UIColor.black.cgColor
        subtractButton.layer.borderWidth = 1
    }
    func addButtonBorderActivate() {
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.layer.borderWidth = 1
    }
    func textFieldBorderActivate() {
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
    }
    
    func resetAddButtonBorder() {
        addButton.layer.borderColor = UIColor.lightGray.cgColor
        addButton.layer.borderWidth = 1
    }
    func resetSubtractButtonBorder() {
        subtractButton.layer.borderColor = UIColor.lightGray.cgColor
        subtractButton.layer.borderWidth = 1
    }
    
    func updateButtonStates() {
        
        if let currentText = textField.text, let currentQuantity = Int(currentText) {
            addButton.isEnabled = currentQuantity < maxQuantity
            subtractButton.isEnabled = currentQuantity > 1
        } else {
            addButton.isEnabled = quantity < maxQuantity
            subtractButton.isEnabled = quantity > 1
        }
        
        if addButton.isEnabled {
            addButtonBorderActivate()
        } else {
            resetAddButtonBorder()
        }
        
        if subtractButton.isEnabled {
            subtractButtonBorderActivate()
        } else {
            resetSubtractButtonBorder()
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let inputQuantity = Int(text), inputQuantity >= 1 && inputQuantity <= maxQuantity {
            quantity = inputQuantity
        } else {
            quantity = 1
        }
        updateButtonStates()
    }
}

// MARK: UITextFieldDelegate
extension CartPageCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if let prospectiveNumber = Int(prospectiveText), prospectiveNumber > 0 {
            return prospectiveNumber <= maxQuantity
        }
        return prospectiveText.isEmpty
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let inputQuantity = Int(text) else {
            textField.text = "1"
            quantity = 1
            updateButtonStates()
            delegate?.didUpdateQuantity(self, quantity: quantity)
            return
        }
        
        if inputQuantity > maxQuantity {
            textField.text = "\(maxQuantity)"
            quantity = maxQuantity
        } else if inputQuantity < 1 {
            textField.text = "1"
            quantity = 1
        } else {
            textField.text = "\(inputQuantity)"
            quantity = inputQuantity
        }
        
        updateButtonStates()
        delegate?.didUpdateQuantity(self, quantity: quantity)
    }
}

