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
    @IBOutlet weak var desc1: UITextView!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var sellerVenmo: UILabel!
    @IBOutlet weak var sellerLocation: UILabel!
    @IBOutlet weak var sellerEmail: UILabel!
    @IBOutlet weak var sellerPhone: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var name = ""
    var desc = ""
    var price = ""
    var venmo = ""
    var img:UIImage = UIImage(named: "avatar-5")!
    var email = ""
    var location = ""
    var phone = ""
    var phoneDigits = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Product Details"
        
        prodTitle.text = name
        desc1.text = desc
        prodPrice.text = price
        sellerVenmo.text = venmo
        prodImage.image = img
        sellerLocation.text = location
        sellerEmail.text = email
        sellerPhone.setTitle(phone, for: .normal)
        
        // Disable delete button for home page
        let parentVC = self.navigationController?.viewControllers[0]
        if (parentVC!.isKind(of: MainPageViewController.self)) {
            deleteButton.isEnabled = false
            deleteButton.setTitle("To delete, go to \"My Profile\"", for: .normal)
        }
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        print("delete")
        deleteItem(database: "items", title: name, username: email);
        deleteItem(database: "users", title: name, username: email)
    }
    
    
    @IBAction func onClickPhoneNumber(_ sender: Any) {
        phoneDigits = phone.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)

        if (phoneDigits.count > 0) {
            clickablePhoneNumber()
        }
    }
    
    func clickablePhoneNumber() {
        
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(phoneDigits)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL);
            }
          }
    }
    
    func displayAlert(isDeleted: Bool) {
//        print("isparent \(navigationController?.viewControllers[0].isKind(of: MyProfileViewController.self))")
        
        if (isDeleted) {
            // Create a new alert
            let deletedAlert = UIAlertController(title: "Yay!", message: "Product successfully deleted!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { (aciton) ->Void in
                print("OK button tapped")
                
                // Go back to either the main page or my profile page depending on where the user navigated from
                let mainPageVC = self.storyboard?.instantiateViewController(withIdentifier: "homepage") as? MainPageViewController
                
                let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "myProfileVC") as? MyProfileViewController
                
                let parentVC = self.navigationController?.viewControllers[0]
                
//                if (parentVC!.isKind(of: MyProfileViewController.self)) {
//                    self.navigationController?.pushViewController(myProfileVC!, animated: true)
//                }
//                else if (parentVC!.isKind(of: MainPageViewController.self)) {
//                    self.navigationController?.pushViewController(mainPageVC!, animated: true)
//                }
                self.navigationController?.popViewController(animated: true)
                
            }
            
            deletedAlert.addAction(ok)
            self.present(deletedAlert, animated: true, completion: nil)
        }
    }
    func deleteItem(database: String, title: String, username: String) {
        var urlStr = ""
//        let ip = "165.106.136.56"
        let ip = "165.106.118.41"
        
        if (database == "items") {
            urlStr = "http://"+ip+":3000/delete?title="+name+"&email="+username
        }
        else {
            urlStr = "http://"+ip+":3000/deleteFromUser?title="+name+"&username="+username
        }
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL(string: urlStr)!
        
        var request = URLRequest(url: url);
        var body = ["test" : ""]
        if (venmo != "") {
            body = ["title":name, "email":username]
        }
        else {
            body = ["title":name, "username":username]
        }
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
    
}
