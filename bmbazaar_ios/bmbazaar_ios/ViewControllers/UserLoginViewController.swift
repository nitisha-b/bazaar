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
    }
    
    @IBAction func onUserLogin(_ sender: Any) {
//        MainPageViewController().modalPresentationStyle = .fullScreen;
        navigationController?.pushViewController(MainPageViewController(), animated: true);
//        performSegue(withIdentifier: "mainpage", sender: self);
    }
    
    @IBAction func onGuestLogin(_ sender: UIButton) {
        navigationController?.pushViewController(MainPageViewController(), animated: true);
    
    }
}
