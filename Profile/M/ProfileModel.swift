import UIKit

struct CellData {
    let imageName: String
    let text: String
}

class ProfileInfo {
    enum Headers: String, CaseIterable {
        case order = "我的訂單"
        case service = "更多服務"
    }
    
    static let shared = ProfileInfo()
    
    let sections = Headers.allCases
    var data: [Headers: [CellData]]
    
    private init() {
        data = [:]
        initializeData()
    }
    
    private func initializeData() {
        data[.order] = [
            CellData(imageName: "AwaitingPayment", text: "待付款"),
            CellData(imageName: "AwaitingShipment", text: "待出貨"),
            CellData(imageName: "Shipped", text: "待簽收"),
            CellData(imageName: "AwaitingReview", text: "待評價"),
            CellData(imageName: "Exchange", text: "退換貨")
        ]
        
        data[.service] = [
            CellData(imageName: "Starred", text: "收藏"),
            CellData(imageName: "Notification", text: "貨到通知"),
            CellData(imageName: "Refunded", text: "帳戶退款"),
            CellData(imageName: "Address", text: "地址"),
            CellData(imageName: "CustomerService", text: "客服訊息"),
            CellData(imageName: "SystemFeedback", text: "系統回饋"),
            CellData(imageName: "RegisterCellphone", text: "手機綁定"),
            CellData(imageName: "Settings", text: "設定")
        ]
    }
}
    
