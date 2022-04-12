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
    }
    
    /*
     * Verifies the user's email address
     * If the email is valid and does not already exist in the database, it creates a new user
     * Saves the email to UserDefaults so it can be used in other view controllers when required
     */
    @IBAction func onClickVerify(_ sender: Any) {
        let email1 = userEmail.text ?? ""
        let email = email1.trimmingCharacters(in: .whitespacesAndNewlines)

        let range = NSRange(location: 0, length: email.utf16.count)
        
        
        let regexPattern = try! NSRegularExpression(pattern:"[a-z1-9]+@brynmawr\\.edu")
        
        if (regexPattern.firstMatch(in: email, options: [], range: range) == nil) {
            errorMessage.text = "Please enter a valid email address"
        }
        else {
            
            //send email to UploadViewController
            let defaults = UserDefaults.standard
            defaults.set(email, forKey: "email")
                defaults.synchronize()

            createUser(email: email)
            errorMessage.text = "Valid!"
            
            
            // If email is valid, navigate to home page
            let tabController = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController
            
            tabController?.modalPresentationStyle = .fullScreen
            self.present(tabController!, animated: true, completion: nil)
        }
    }
    
    /*
     * Uses the POST endpoint to create a new user in the database
     * Creates a new user in the MongoDB database if it is not an existing user
     */
    func createUser(email: String) {
        let ip = "165.106.118.41"
//        let ip = "165.106.136.56"
        let localhost = "localhost"

        var urlStr = "http://"+ip+":3000/createUser?username="+email;

        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: urlStr)!;

        var request = URLRequest(url: url);

        let body = ["username": email];

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
}

