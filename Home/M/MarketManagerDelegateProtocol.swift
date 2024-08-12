import UIKit
import Foundation

protocol MarketManagerDelegate {

    func manager(_ manager: MarketManager, didGet marketingHots: [MarketingSection])
    func manager(_ manager: MarketManager, didFailWith error: Error)
}

protocol ConfigurableCell {
    func configure(with product: Product)
}
