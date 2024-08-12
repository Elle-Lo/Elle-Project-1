import UIKit
import Foundation
import Alamofire
import FacebookLogin

struct StylishUserProfile: Decodable {
    let name: String
    let picture: String
    
}

struct StylishUserResponse: Decodable {
    let data: StylishUserProfile
}


// MARK: ProfileViewController
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personSpending: UILabel!
    
    // MARK: CollectionView Outlet
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            collectionView.collectionViewLayout = layout
            collectionView.backgroundColor = .white
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        personName.text = "Elle"
        personSpending.text = "累計消費 NT$99999"
        personImage.layer.cornerRadius = 35
        personImage.clipsToBounds = true
        fetchStylishUserProfile()
    }
    
    // MARK: Fetch STYLiSH Profile
    func fetchStylishUserProfile() {
        guard let token = getToken() else {
            print("No stylish token")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("https://api.appworks-school.tw/api/1.0/user/profile", method: .get, headers: headers)
            .responseDecodable(of: StylishUserResponse.self) { response in
                switch response.result {
                case .success(let userProfileResponse):
                    self.updateUserProfile(data: userProfileResponse.data)
                case .failure(let error):
                    print("Failed to fetch user profile: \(error.localizedDescription)")
                }
            }
    }
    
    func getToken() -> String? {
        if let data = KeychainService.load(key: "StylishToken") {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func updateUserProfile(data: StylishUserProfile) {
        personName.text = data.name
        if let url = URL(string: data.picture) {
            downloadImage(from: url)
        }
    }
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.personImage.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}


// MARK: CollectionView
extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ProfileInfo.shared.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let header = ProfileInfo.shared.sections[section]
        return ProfileInfo.shared.data[header]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let header = ProfileInfo.shared.sections[indexPath.section]
        guard let data = ProfileInfo.shared.data[header] else {
            return UICollectionViewCell()
        }
        let cellData = data[indexPath.row]
        
        switch header {
        case .order:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            cell.configure(with: cellData)
            return cell
        case .service:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            cell.configure(with: cellData)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let profileHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.reuseIdentifier, for: indexPath) as? ProfileHeaderView else {
            fatalError("Can't create a profileHeaderView!")
        }
        
        let section = ProfileInfo.shared.sections[indexPath.section]
        profileHeaderView.textLabel.text = section.rawValue
        profileHeaderView.seeAllButton.isHidden = section == .service
        return profileHeaderView
    }
}


extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = ProfileInfo.shared.sections[indexPath.section]
        let padding: CGFloat = 35
        let itemsPerRow: CGFloat
        let interItemSpacing: CGFloat
        
        if section == .order {
            itemsPerRow = 5
            interItemSpacing = padding * (itemsPerRow - 1)
        } else if section == .service {
            itemsPerRow = 4
            interItemSpacing = padding * (itemsPerRow - 1)
        } else {
            return CGSize(width: 60, height: 50)
        }
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - interItemSpacing
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}


extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let header = ProfileInfo.shared.sections[indexPath.section]
        switch header {
        case .order:
            print("點擊了我的訂單 \(indexPath.row + 1)")
            
        case .service:
            print("點擊了更多服務 \(indexPath.row + 1)")
            
        }
    }
}
