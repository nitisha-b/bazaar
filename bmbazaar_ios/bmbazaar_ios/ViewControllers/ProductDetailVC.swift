//
//  ProductDetailVC.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/22/22.
//

import Foundation
import UIKit

class ProductDetailsVC: UIViewController {
    
    @IBOutlet weak var prodTitle: UILabel!
    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var prodDesc: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var sellerVenmo: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var name = ""
    var desc = ""
    var price = ""
    var venmo = ""
    var seller = ""
    var img:UIImage = UIImage(named: "avatar-5")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Details"
        
        
        
        prodTitle.text = name
        prodDesc.text = desc
        prodPrice.text = price
        sellerVenmo.text = venmo
        sellerName.text = seller
        prodImage.image = img
        print(name)
      
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        
        var urlStr = "http://localhost:3000/delete?title="+name+"&venmo="+venmo
        print("url \(urlStr)")
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL(string: urlStr)!
        
        var request = URLRequest(url: url);
        
        let body = ["title":name, "venmo":venmo]
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Set http method
        request.httpMethod = "DELETE"
        request.httpBody = bodyData
        
        var isDeleted = false;
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print("Error: error calling DELETE")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            isDeleted = true
            
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
                
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
            // Show alert
            DispatchQueue.main.async {
                self.displayAlert(isDeleted: isDeleted)
            }
        }
        task.resume()
    }
    
    func displayAlert(isDeleted: Bool) {
        
        if (isDeleted) {
            // Create a new alert
            let deletedAlert = UIAlertController(title: "Yay!", message: "Product successfully deleted!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { (aciton) ->Void in
                print("OK button tapped")
                
                // Go back to the main page
                let mainPageVC = self.storyboard?.instantiateViewController(withIdentifier: "homepage") as? MainPageViewController
                self.navigationController?.pushViewController(mainPageVC!, animated: true)
            }
            
            deletedAlert.addAction(ok)
            self.present(deletedAlert, animated: true, completion: nil)
        }
    }
    
}
