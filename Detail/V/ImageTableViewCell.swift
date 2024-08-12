import UIKit
import Foundation

// MARK: ImageTableViewCell
class ImageTableViewCell: UITableViewCell {
    
    var currentPage: Int = 0
    var image: String?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func pageControl(_ sender: UIPageControl) {
        let pageIndex = sender.currentPage
        let xOffset = CGFloat(pageIndex) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        print("Selected Page Index: \(pageIndex)")
    }
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    func configure(with product: Product) {
        let imageViews = [image1, image2, image3, image4]
        for (index, imageUrl) in product.images.prefix(4).enumerated() {
            imageViews[index]?.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "Image_Placeholder"))
        }
        pageControl.numberOfPages = product.images.count
        scrollView.delegate = self
    }
}

// MARK: UIScrollViewDelegate
extension ImageTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pageControl.currentPage = Int(page)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            let page = scrollView.contentOffset.x / scrollView.bounds.width
            pageControl.currentPage = Int(page)
        }
}
