//
//  UserLoginViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/7/22.
//

import Foundation
import UIKit

class UserLoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        guestLoginButton.adjustsImageSizeForAccessibilityContentSizeCategory = true;
        
      
    }
    
    @IBAction func onUserLogin(_ sender: Any) {
        performSegue(withIdentifier: "toMainPage", sender: self);
        isModalInPresentation.toggle();
        
    }
    
    
    @IBAction func onGuestLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "toMainPage", sender: self);
        isModalInPresentation.toggle();
    }
    
    
}
