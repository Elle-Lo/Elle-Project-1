import UIKit
import Foundation

class MarketManager {
    
    var delegate: MarketManagerDelegate?
    
    func getMarketingHots() {
        
        let url = "https://api.appworks-school.tw/api/1.0/marketing/hots"
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                print("Invalid response!")
                return
            }
            
            guard let data = data else {
                print("No data!")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let marketingHots = try decoder.decode(Hots.self, from: data)
                let marketingSections = marketingHots.data
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGet: marketingSections)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                }
            }
        }
        task.resume()
    }
}
