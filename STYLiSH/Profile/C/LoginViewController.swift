import UIKit
import Alamofire
import FBSDKLoginKit
import FacebookLogin


// MARK: LoginViewController
class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeButoonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginWithFacebook(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Facebook login failed: \(error.localizedDescription)")
            } else if let result = result, !result.isCancelled {
                if let tokenString = AccessToken.current?.tokenString {
                    let saveStatus = KeychainService.save(key: "FacebookToken", data: tokenString.data(using: .utf8)!)
                    if saveStatus == errSecSuccess {
                    } else {
                        print("Failed to save Facebook AccessToken in Keychain with status: \(saveStatus)")
                    }
                    self.getStylishToken(facebookToken: tokenString)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func saveFacebookToken(_ tokenString: String) {
        let saveStatus = KeychainService.save(key: "FacebookToken", data: tokenString.data(using: .utf8)!)
        if saveStatus == errSecSuccess {
            print("Facebook AccessToken successfully saved in Keychain.")
        } else {
            print("Failed to save Facebook AccessToken in Keychain with status: \(saveStatus)")
        }
    }
    
    private func fetchFacebookUserProfile(completion: @escaping (String?, String?) -> Void) {
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large)"])
        graphRequest.start { _, result, error in
            if let error = error {
                print("Failed to fetch Facebook user profile: \(error.localizedDescription)")
                completion(nil, nil)
            } else if let userData = result as? [String: Any],
                      let picture = userData["picture"] as? [String: Any],
                      let data = picture["data"] as? [String: Any],
                      let pictureUrl = data["url"] as? String {
                let name = userData["name"] as? String
                completion(name, pictureUrl)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    // MARK: Get STYLish Token
    func getStylishToken(facebookToken: String) {
        let parameters: [String: Any] = [
            "provider": "facebook",
            "access_token": facebookToken
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request("https://api.appworks-school.tw/api/1.0/user/signin", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let data = json["data"] as? [String: Any], let token = data["access_token"] as? String {
                    
                    self.saveToken(token)
                    self.navigateToProfile()
                    print("Successfully received STYLiSH token: \(token)")
                } else {
                    print("Failed to parse token from response.")
                }
            case .failure(let error):
                print("Failed to get STYLiSH token: \(error.localizedDescription)")
            }
        }
    }
    
    func saveToken(_ token: String) {
        if let data = token.data(using: .utf8) {
            let status = KeychainService.save(key: "StylishToken", data: data)
            if status == errSecSuccess {
            } else {
                print("Failed to save token in Keychain.")
            }
        }
    }
    
    func navigateToProfile() {
        if let tabBarController = self.presentingViewController as? CustomTabBarController {
            self.dismiss(animated: true, completion: {
                tabBarController.selectedIndex = 3
            })
        }
    }
    
}
