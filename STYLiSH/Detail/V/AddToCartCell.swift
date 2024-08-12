import UIKit
import Foundation

// MARK: Protocol: AddToCartCellDelegate
protocol AddToCartCellDelegate: AnyObject {
    func didUpdateSelection(status: Bool)
    func collectSelectedInfo(selectColor: String?, selectSize: String?, currentQty: String?, selectStock: String?)
}

// MARK: AddToCartCell
class AddToCartCell: UITableViewCell {
    
    //MARK: Outlet
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var colorButton1: UIButton!
    @IBOutlet weak var colorButton2: UIButton!
    @IBOutlet weak var colorButton3: UIButton!
    @IBOutlet weak var sizeButton1: UIButton!
    @IBOutlet weak var sizeButton2: UIButton!
    @IBOutlet weak var sizeButton3: UIButton!
    @IBOutlet weak var sizeButton4: UIButton!
    
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.borderColor = UIColor.lightGray.cgColor
            addButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var subtractButton: UIButton! {
        didSet {
            subtractButton.layer.borderColor = UIColor.lightGray.cgColor
            subtractButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var numberTextField: UITextField! {
        didSet {
            numberTextField.layer.borderColor = UIColor.lightGray.cgColor
            numberTextField.layer.borderWidth = 1
            numberTextField.isEnabled = false
            numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    //MARK: Function
    @IBAction func tapColorButton1(_ sender: Any) { colorButtonTapped(colorButton1) }
    @IBAction func tapColorButton2(_ sender: Any) { colorButtonTapped(colorButton2) }
    @IBAction func tapColorButton3(_ sender: Any) { colorButtonTapped(colorButton3) }
    
    @IBAction func tapSizeButton1(_ sender: UIButton) { sizeButtonTapped(sizeButton1) }
    @IBAction func tapSizeButton2(_ sender: UIButton) { sizeButtonTapped(sizeButton2) }
    @IBAction func tapSizeButton3(_ sender: UIButton) { sizeButtonTapped(sizeButton3) }
    @IBAction func tapSizeButton4(_ sender: UIButton) { sizeButtonTapped(sizeButton4) }
    
    @IBAction func subtractButton(_ sender: Any) {
        if let currentText = numberTextField.text, let currentQuantity = Int(currentText), currentQuantity > 1 {
                quantity = currentQuantity - 1
                numberTextField.text = "\(quantity)"
                currentQty = String(quantity)
                updateButtonStates()
            delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
            }
        print("collectSelectedInfo called with currentQty: \(currentQty ?? "nil")")
    }
    @IBAction func addButton(_ sender: Any) {
        if let currentText = numberTextField.text, let currentQuantity = Int(currentText), currentQuantity < sumStock {
                quantity = currentQuantity + 1
                numberTextField.text = "\(quantity)"
                currentQty = String(quantity)
                updateButtonStates()
            delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
            }
    }
    
    //MARK: Properties
    weak var delegate: AddToCartCellDelegate?
    
    var data : Product?
    var quantity: Int = 1
    var sumStock : Int = 0
    var selectSize: String?
    var selectColor: String?
    var currentQty: String? = "1"
    var selectStock: String?
    
    lazy var colorButtons = [colorButton1, colorButton2, colorButton3]
    lazy var sizeButtons = [sizeButton1, sizeButton2, sizeButton3, sizeButton4]
    var currentProduct: Product? {
        didSet {
            guard let product = currentProduct else { return }
            configure(with: product)
        }
    }
    
    //MARK: Scene
    override func awakeFromNib() {
        super.awakeFromNib()
        numberTextField.keyboardType = .numberPad
        numberTextField.textAlignment = .center
        numberTextField.textColor = .black
        numberTextField.delegate = self
        numberTextField.text = ""
        stockLabel.text = ""
    }
    
    func reset() {
            for button in colorButtons {
                button?.layer.sublayers?.filter { $0.name == "InnerBorder" }.forEach { $0.removeFromSuperlayer() }
                button?.layer.borderColor = UIColor.clear.cgColor
                button?.layer.borderWidth = 0
            }
            
            for button in sizeButtons {
                button?.layer.sublayers?.filter { $0.name == "InnerBorder" }.forEach { $0.removeFromSuperlayer() }
                button?.layer.borderColor = UIColor.clear.cgColor
                button?.layer.borderWidth = 0
                button?.isEnabled = false
            }
            
            quantity = 1
            currentQty = "1"
            numberTextField.text = "1"
            numberTextField.isEnabled = false
            
            stockLabel.text = ""
            
            addButton.isEnabled = false
            subtractButton.isEnabled = false
            resetAddButtonBorder()
            resetSubtractButtonBorder()
            
            selectColor = nil
            selectSize = nil
            
            delegate?.didUpdateSelection(status: false)
            delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
        }
    
    private func handleAddToCart() {
            reset()
        }
    
    //MARK: Cell
    func configure(with product: Product) {
        productNameLabel.text = product.title
        priceLabel.text = "NT$\(product.price)"
        configureColorButtons(with: product.colors)
        configureSizeButtons(with: product.sizes, variants: product.variants)
        data = product
    }
    
    private func configureColorButtons(with colors: [Color]) {
        for (index, color) in colors.prefix(3).enumerated() {
            let button = colorButtons[index]
            button?.isHidden = false
            if let uiColor = UIColor(hex: color.code) {
                button?.backgroundColor = uiColor
            }
            button?.layer.borderColor = UIColor.clear.cgColor
            button?.layer.borderWidth = 0
            button?.setTitle("", for: .normal)
            button?.tag = index
        }
        
        for index in colors.count..<colorButtons.count {
            colorButtons[index]?.isHidden = true
        }
    }
    
    func configureSizeButtons(with sizes: [String], variants: [Variant]) {
        for button in sizeButtons {
            button?.isEnabled = false
            button?.isHidden = true
        }
        
        for (index, size) in sizes.prefix(4).enumerated() {
            let button = sizeButtons[index]
            button?.isHidden = false
            button?.setTitle(size, for: .normal)
            button?.layer.borderColor = UIColor.clear.cgColor
            button?.layer.borderWidth = 0
            button?.tag = index
        }
    }
    
    //MARK: Add/Subtract/TextField ButtonBorder
    func subtractButtonBorderActivate() {
        subtractButton.layer.borderColor = UIColor.black.cgColor
        subtractButton.layer.borderWidth = 1
    }
    func addButtonBorderActivate() {
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.layer.borderWidth = 1
    }
    func textFieldBorderActivate() {
        numberTextField.layer.borderColor = UIColor.black.cgColor
        numberTextField.layer.borderWidth = 1
    }
    
    func resetAddButtonBorder() {
        addButton.layer.borderColor = UIColor.lightGray.cgColor
        addButton.layer.borderWidth = 1
    }
    func resetSubtractButtonBorder() {
        subtractButton.layer.borderColor = UIColor.lightGray.cgColor
        subtractButton.layer.borderWidth = 1
    }
    
    //MARK: Color/Size/TextField ButtonFunction
    @objc private func colorButtonTapped(_ sender: UIButton) {
        
        for button in colorButtons {
            button?.layer.sublayers?.filter { $0.name == "InnerBorder" }.forEach { $0.removeFromSuperlayer() }
            button?.layer.borderColor = UIColor.clear.cgColor
            button?.layer.borderWidth = 0
        }
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = 1
        
        let innerBorder = CALayer()
        innerBorder.name = "InnerBorder"
        innerBorder.frame = sender.bounds.insetBy(dx: 0, dy: 0)
        innerBorder.borderColor = UIColor.white.cgColor
        innerBorder.borderWidth = 3
        innerBorder.cornerRadius = sender.layer.cornerRadius
        innerBorder.masksToBounds = true
        sender.layer.addSublayer(innerBorder)
        
        numberTextField.text = ""
        numberTextField.isEnabled = false
        numberTextField.layer.borderColor = UIColor.lightGray.cgColor
        addButton.isEnabled = false
        resetAddButtonBorder()
        resetSubtractButtonBorder()
        
        for button in sizeButtons {
            button?.isEnabled = true
        }
        
        selectColor = data?.colors[sender.tag].code
        
        for i in 0..<(data?.variants.count)! {
            if data?.variants[i].colorCode == selectColor {
                if data?.variants[i].stock == 0 {
                    for j in 0..<sizeButtons.count {
                        if sizeButtons[j]?.titleLabel?.text == data?.variants[i].size {
                            sizeButtons[j]?.isEnabled = false
                        }
                    }
                }
            }
        }
        
        if selectColor == selectColor {
            for button in sizeButtons {
                button?.layer.sublayers?.filter { $0.name == "InnerBorder" }.forEach { $0.removeFromSuperlayer() }
                button?.layer.borderColor = UIColor.clear.cgColor
                button?.layer.borderWidth = 0
                stockLabel.text = ""
            }
        }
        
        delegate?.didUpdateSelection(status: false)
        delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
    }
    
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        sumStock = 0
        for button in sizeButtons {
            button?.layer.sublayers?.filter { $0.name == "InnerBorder" }.forEach { $0.removeFromSuperlayer() }
            button?.layer.borderColor = UIColor.clear.cgColor
            button?.layer.borderWidth = 0
        }
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = 1
        
        let innerBorder = CALayer()
        innerBorder.name = "InnerBorder"
        innerBorder.frame = sender.bounds.insetBy(dx: 0, dy: 0)
        innerBorder.borderColor = UIColor.white.cgColor
        innerBorder.borderWidth = 3
        innerBorder.cornerRadius = sender.layer.cornerRadius
        innerBorder.masksToBounds = true
        sender.layer.addSublayer(innerBorder)
        selectSize = data?.sizes[sender.tag]
        
        addButtonBorderActivate()
        textFieldBorderActivate()
        numberTextField.text = "1"
        quantity = 1
        numberTextField.isEnabled = true
        addButton.isEnabled = true
        numberTextField.isEnabled = true
        
        for variant in data?.variants ?? [] {
            if variant.colorCode == selectColor && variant.size == selectSize {
                sumStock += variant.stock
            }
        }
        
        stockLabel.text = "庫存：\(sumStock)"
        selectStock = String(sumStock)
        updateButtonStates()

        delegate?.didUpdateSelection(status: true)
        delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let inputQuantity = Int(text), inputQuantity >= 1 && inputQuantity <= sumStock {
            quantity = inputQuantity
            currentQty = String(quantity)
        } else {
            quantity = 1
        }
        updateButtonStates()
        delegate?.collectSelectedInfo(selectColor: selectColor, selectSize: selectSize, currentQty: currentQty, selectStock: selectStock)
        
    }
    
    private func updateButtonStates() {
        addButton.isEnabled = quantity < sumStock
        subtractButton.isEnabled = quantity > 1
        
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
        if sumStock == 1 {
            addButton.isEnabled = false
            subtractButton.isEnabled = false
        }
    }
}

//MARK: UITextFieldDelegate
extension AddToCartCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if let prospectiveNumber = Int(prospectiveText), prospectiveNumber > 0 {
            return prospectiveNumber <= sumStock
        }
        return prospectiveText.isEmpty
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let inputQuantity = Int(text) else {
            textField.text = "1"
            quantity = 1
            updateButtonStates()

            return
        }

        if inputQuantity > sumStock {
            textField.text = "\(sumStock)"
            quantity = sumStock
        } else if inputQuantity < 1 {
            textField.text = "1"
            quantity = 1
        } else {
            textField.text = "\(inputQuantity)"
            quantity = inputQuantity
        }
        
        updateButtonStates()
        currentQty = String(quantity)

    }
}

