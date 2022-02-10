//
//  MainPageViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/7/22.
//

import Foundation
import UIKit

class MainPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackButton(_ sender: UIButton!) {
    //        navigationController?.popViewController(animated: true);
            
    //        navigationController?.isModalInPresentation = false;
            navigationController?.popToViewController(MainPageViewController(), animated: true)

//            self.dismiss(animated: true, completion: nil)
    //        dismiss(animated: true, completion: nil);
            
    }
    
}
