//
//  MainPageViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/7/22.
//

import Foundation
import UIKit

class MainPageViewController: UIViewController {
    
    func onLoad() {
        let url = URL(string: "https://http://localhost:3000/api")

        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Convert HTTP Response Data to a simple String
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let results = json["results"] as? [[String: Any]] {
                        for result in results {
                            print(result)
                        }
                    }
                } catch {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }

        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func onBackButton(_ sender: UIButton!) {
//        let viewController = UIViewController()
//        viewController.modalPresentationStyle = .fullScreen
//        present(viewController, animated: true, completion: nil)
    //        navigationController?.popViewController(animated: true);
            
    //        navigationController?.isModalInPresentation = false;
            navigationController?.popToViewController(MainPageViewController(), animated: true)

//            self.dismiss(animated: true, completion: nil)
    //        dismiss(animated: true, completion: nil);
            
    }
    
}
