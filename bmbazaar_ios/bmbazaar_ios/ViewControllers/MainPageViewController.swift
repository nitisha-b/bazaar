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
    
    var items = [Item]()
//
//    var items2: [Item] = [
//            Item(title: "hehe", description: "hehe", price: 10.0),
//            Item(title: "boom", description: "hehe", price: 10.0),
//            Item(title: "a", description: "hehe", price: 10.0)
//         ]
        
    
    func onLoad() {
        let url = URL(string: "http://localhost:3000/api")

        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Convert HTTP Response Data to a simple String
            if let data = data {
                do {
//                    print(String (data: data, encoding: .utf8)!)
                    guard let json = try? JSONDecoder().decode([Item].self, from: data) else {
                        print("Error: Couldn't decode data into cars array")
                        return
                    }
                    for item in json {
                        items.append(item)
                    }
                } catch {
                    print("Failed to load: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }

        }
        task.resume()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        onLoad()
    }

}

extension MainPageViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.size.width/CGFloat(Float(items.count)))
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.setup(with: items[indexPath.row])
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

extension MainPageViewController: UICollectionViewDelegate {
    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC

        detailsVC?.title = items[indexPath.row].title.description
        self.navigationController?.pushViewController(detailsVC!, animated: true)

        let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC
//
//        detailsVC?.title = items[indexPath.row].title.description
//        self.navigationController?.pushViewController(detailsVC!, animated: true)
//    }
}
