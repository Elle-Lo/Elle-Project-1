import UIKit
import Foundation
import Alamofire
import Kingfisher
import MJRefresh

// MARK: MenClothesViewController
class MenClothesViewController: UIViewController {
    
    @IBOutlet weak var menClothesCollectionView: UICollectionView! {
        didSet {
            menClothesCollectionView.dataSource = self
            menClothesCollectionView.delegate = self
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            menClothesCollectionView.collectionViewLayout = layout
            menClothesCollectionView.backgroundColor = .white
            
            MJRefreshConfig.default.languageCode = "En"
            menClothesCollectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
            menClothesCollectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
            
        }
    }
    
    var products = [Product]()
    var nextPaging: Int? = nil
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
    }
    
    // MARK: Data
    @objc func refreshData() {
        nextPaging = 0
        fetchData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowMenDetailSegue",
               let detailVC = segue.destination as? DetailViewController,
               let product = sender as? Product {
                detailVC.product = product
            }
        }
    
    let urlBase = "https://api.appworks-school.tw/api/1.0/products/men"
    
    func fetchData() {
        
        AF.request(urlBase).responseDecodable(of: ProductResponse.self) { response in
            DispatchQueue.main.async {
                self.menClothesCollectionView.mj_header?.endRefreshing()
                
                switch response.result {
                case .success(let productResponse):
                    if self.nextPaging == 0 {
                        self.products = productResponse.data
                    } else {
                        self.products.append(contentsOf: productResponse.data)
                    }
                    
                    self.nextPaging = productResponse.nextPaging
                    
                    if self.nextPaging == nil {
                        self.menClothesCollectionView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        self.menClothesCollectionView.mj_footer?.endRefreshing()
                    }
                    
                    self.menClothesCollectionView.reloadData()
                    
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    self.menClothesCollectionView.mj_footer?.endRefreshing()
                }
            }
        }
        
    }
    
    @objc func loadMoreData() {
        guard let nextPaging = nextPaging else {
            self.menClothesCollectionView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        
        let url = urlBase + "?paging=\(nextPaging)"
        
        AF.request(url).responseDecodable(of: ProductResponse.self) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let productResponse):
                    self.products.append(contentsOf: productResponse.data)
                    self.nextPaging = productResponse.nextPaging
                    self.menClothesCollectionView.reloadData()
                    
                    if productResponse.nextPaging == nil {
                        self.menClothesCollectionView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        self.menClothesCollectionView.mj_footer?.endRefreshing()
                    }
                    
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    self.menClothesCollectionView.mj_footer?.endRefreshing()
                }
            }
        }
    }
}


// MARK: CollectionView
extension MenClothesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenClothesCell", for: indexPath) as! MenClothesCell
        
        let product = products[indexPath.row]
        cell.configure(with: product)
        
        return cell
    }
}

extension MenClothesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 70
        let itemsPerRow: CGFloat = 2
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - padding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 320)
    }
}

extension MenClothesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: "ShowMenDetailSegue", sender: selectedProduct)
        print("Selected product: \(selectedProduct.title)")
        
    }
}

