//
//  MainPageViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/7/22.
//

import Foundation
import UIKit

class MainPageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Item] = [
            Item(title: "Pants", description: "comfy", price: 10.00, seller: "nitisha"),
            Item(title: "shirt", description: "cotton", price: 5.50, seller: "nigina"),
            Item(title: "book", description: "mathematics", price: 10.50, seller: "sarah")
        ]
    
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
        collectionView.dataSource = self
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

extension MainPageViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.setup(with: items[indexPath.row])
        return cell
    }
}
