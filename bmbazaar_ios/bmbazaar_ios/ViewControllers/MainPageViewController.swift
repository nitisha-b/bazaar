//
//  MainPageViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/7/22.
//

import Foundation
import UIKit
import AWSCore
import AWSS3

class MainPageViewController: UIViewController, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = [Item]()
    var images = [Image]()
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
                        
                        
                        let url = NSURL(string: "https://brynmawrbazaar.s3.amazonaws.com/" + item.image);
                        var err: NSError?
                        var imageData :NSData = try! NSData(contentsOf: url as! URL,options: NSData.ReadingOptions.mappedIfSafe)
                        var bgImage = UIImage(data:imageData as Data)
                        var i = Image(image: bgImage!, title: item.title)
                        images.append(i)
                        
                        //item.image = bgImage
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
        cell.setup(with: items[indexPath.row], with: images[indexPath.row])
        //cell.itemImage.contentMode = UIView.ContentMode.center
        
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

extension MainPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC

        // Set values for product details
        detailsVC?.name = items[indexPath.row].title
        detailsVC?.desc = items[indexPath.row].description
        detailsVC?.price = items[indexPath.row].price.description
        detailsVC?.venmo = items[indexPath.row].venmo
        
        
        // Show details view controller
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}


