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
        
        if (regexPattern.firstMatch(in: email, options: [], range: range) == nil) {
            errorMessage.text = "Please enter a valid email address"
        }
        else {
            errorMessage.text = "Valid!"
            
            // If email is valid, navigate to home page
            let tabController = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController
            
            tabController?.modalPresentationStyle = .fullScreen
            self.present(tabController!, animated: true, completion: nil)
        }
    }
}
