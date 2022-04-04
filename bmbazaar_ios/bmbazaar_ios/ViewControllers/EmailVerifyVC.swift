//
//  EmailVerifyVC.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 3/16/22.
//

import Foundation
import UIKit

class EmailVerifyVC: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var username: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify User"
        errorMessage.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickVerify(_ sender: Any) {
        let email = userEmail.text ?? ""
        
        let range = NSRange(location: 0, length: email.utf16.count)
        
        
        let regexPattern = try! NSRegularExpression(pattern:"[a-z1-9]+@brynmawr\\.edu")
        
        //let regexPattern = try! NSRegularExpression(pattern:"[a-z1-9]*")
        
        if (regexPattern.firstMatch(in: email, options: [], range: range) == nil) {
            errorMessage.text = "Please enter a valid email address"
        }
        else {
            
            //send email to UploadViewController
            let defaults = UserDefaults.standard
            defaults.set(self.userEmail.text!,forKey: "email")
                defaults.synchronize()
            
            //print(email);
            createUser(email: email)
            errorMessage.text = "Valid!"
            
            
            // If email is valid, navigate to home page
            let tabController = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController
            
            tabController?.modalPresentationStyle = .fullScreen
            self.present(tabController!, animated: true, completion: nil)
        }
    }
    
    func createUser(email: String) {
        let ip = "165.106.136.56"
        let localhost = "localhost"
//        var urlStr = "http://165.106.136.56:3000/createUser?username="+email;
        var urlStr = "http://"+ip+":3000/createUser?username="+email;
//                var urlStr = "http://localhost:3000/create?"+title+desc+ven+loc+price+"&isService="+String(isService);
        //        print(urlStr);
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: urlStr)!;

        var request = URLRequest(url: url);

        let body = ["username": email];
        //        let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":isService] as [String : Any];
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])

        request.httpMethod = "POST"
        request.httpBody = bodyData;
        var isPosted = false;
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                print("Data successfully posted in the database! \(data)")
                isPosted = true
            }
            else if let error = error {
                print("Http request failed \(error)")
            }
        }
        task.resume()
    }
//    func saveUserName {
//        return username
//    }
}

