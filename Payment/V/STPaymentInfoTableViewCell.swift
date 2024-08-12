import UIKit
import TPDirect

// MARK: PaymentMethod
enum PaymentMethod: String {
    case creditCard = "信用卡付款"
    case cash = "貨到付款"
}

// MARK: Protocol STPaymentInfoTableViewCellDelegate
protocol STPaymentInfoTableViewCellDelegate: AnyObject {
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell)
    func didUpdateUserInfoValidStatus(_ isValid: Bool)
    func checkout(_ cell:STPaymentInfoTableViewCell)
    func presentSuccessViewController()
}

// MARK: STPaymentInfoTableViewCell
class STPaymentInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentTextField: UITextField! {
        didSet {
            let shipPicker = UIPickerView()
            shipPicker.dataSource = self
            shipPicker.delegate = self
            
            paymentTextField.inputView = shipPicker
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            button.setBackgroundImage(UIImage.asset(.Icons_24px_DropDown), for: .normal)
            
            button.isUserInteractionEnabled = false
            paymentTextField.rightView = button
            paymentTextField.rightViewMode = .always
            paymentTextField.delegate = self
            paymentTextField.text = PaymentMethod.cash.rawValue
        }
    }
    @IBOutlet weak var creditView: UIView! {
        didSet {
            creditView.isHidden = true
            creditView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        }
    }
    
    @IBOutlet weak var creditViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var shipPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var productAmountLabel: UILabel!
    @IBOutlet weak var topDistanceConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBAction  func checkout() {
        delegate?.checkout(self)
        
        guard isUserInfoValid else { return }
        let isPaymentMethodCash = paymentTextField.text == PaymentMethod.cash.rawValue
        if isPaymentMethodCash {
            goToSuccessPage()
            print("Pay by cash")
        } else if tpdStatus?.isCanGetPrime() == true {
            goToSuccessPage()
            getPrime()
        } else {
            print("Form is not valid")
        }
    }
    
    private let paymentMethod: [PaymentMethod] = [.cash, .creditCard]
    weak var delegate: STPaymentInfoTableViewCellDelegate?
    
    var tpdCard: TPDCard!
    var tpdForm: TPDForm!
    var tpdStatus: TPDStatus?
    var isUserInfoValid = false
    
    // MARK: awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        checkoutButton.isEnabled = false
        checkoutButton.backgroundColor = UIColor.lightGray
        
        self.tpdForm = TPDForm.setup(withContainer: creditView)
        tpdForm.setErrorColor(UIColor.red)
        tpdForm.setOkColor(UIColor.green)
        tpdForm.setNormalColor(UIColor.black)
        self.tpdCard = TPDCard.setup(tpdForm)
        tpdForm.onFormUpdated { [weak self] (status: TPDStatus) in
            guard let self = self else { return }
            self.tpdStatus = status
            self.updateCheckoutButtonState()
        }
    }
    
    func layoutCellWith(productPrice: Int, shipPrice: Int, productCount: Int) {
        productPriceLabel.text = "NT$ \(productPrice)"
        shipPriceLabel.text = "NT$ 60"
        totalPriceLabel.text = "NT$ \(shipPrice + productPrice)"
        productAmountLabel.text = "總計 (\(productCount)樣商品)"
    }
    
    func updateCheckoutButtonState() {
        let isPaymentMethodCash = paymentTextField.text == PaymentMethod.cash.rawValue
        
        if isUserInfoValid && (isPaymentMethodCash || (tpdStatus?.isCanGetPrime() ?? false)) {
            checkoutButton.isEnabled = true
            checkoutButton.backgroundColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
        } else {
            checkoutButton.isEnabled = false
            checkoutButton.backgroundColor = UIColor.lightGray
        }
    }
    
    func getPrime() {
        tpdCard.onSuccessCallback { [weak self] (prime, cardInfo, cardIdentifier, optional) in
            guard let self = self else { return }
            print("Prime: \(prime!), cardInfo: \(cardInfo!), cardIdentifier: \(cardIdentifier!)")
            DispatchQueue.main.async {
                self.checkoutButton.isEnabled = true
                self.checkoutButton.backgroundColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
            }
        }.onFailureCallback { [weak self] (status, message) in
            guard let self = self else { return }
            print("Status: \(status), Message: \(message)")
            DispatchQueue.main.async {
                self.checkoutButton.isEnabled = false
                self.checkoutButton.backgroundColor = UIColor.lightGray
            }
        }.getPrime()
    }
    
    func goToSuccessPage() {
        delegate?.presentSuccessViewController()
    }
}

// MARK: UIPickerView
extension STPaymentInfoTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return paymentMethod[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        paymentTextField.text = paymentMethod[row].rawValue
    }
    
    private func manipulateHeight(_ distance: CGFloat) {
        topDistanceConstraint.constant = distance
        delegate?.didChangePaymentMethod(self)
    }
}

// MARK: UITextFieldDelegate
extension STPaymentInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != paymentTextField {
            return
        }
        guard
            let text = textField.text,
            let payment = PaymentMethod(rawValue: text) else
        {
            return
        }
        switch payment {
        case .cash:
            manipulateHeight(44)
            creditView.isHidden = true
            creditViewTopConstraint.constant = 0
            
        case .creditCard:
            manipulateHeight(150)
            creditView.isHidden = false
            creditViewTopConstraint.constant = 30
        }
        updateCheckoutButtonState()
    }
}




