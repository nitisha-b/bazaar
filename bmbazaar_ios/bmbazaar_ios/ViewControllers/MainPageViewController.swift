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
    
        var items: [Item] = []
        
    
    
    func onLoad() {
        let url = URL(string: "http://localhost:3000/api")

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
//            guard let response = response as? HTTPURLResponse else { return }
//            if response.statusCode == 200 {
//                guard let data = data else { return }
//                      DispatchQueue.main.async {
//                          do {
//                              let decodedUsers = try JSONDecoder().decode([Item].self, from: data)
//                              self.items = decodedUsers
//                          } catch let error {
//                              print("Error decoding: ", error)
//                          }
//                      }
//                  }

            // Convert HTTP Response Data to a simple String
            if let data = data {
                do {
                    let str = String(decoding: request.httpBody!, as: UTF8.self)
                    print("BODY \n \(str)")
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]] {
                        for result in results {
                            print(result)
                        }
                    }
                    else {
                        print("data may be corrupted")
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
        collectionView.delegate = self
        onLoad()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
}

extension MainPageViewController: UICollectionViewDelegate {
    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell
        return cell
    }
}
