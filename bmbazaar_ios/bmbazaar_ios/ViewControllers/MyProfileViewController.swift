//
//  MyProfileViewController.swift
//  bmbazaar_ios
//
//  Created by Nigina Daniyarova on 3/23/22.
//

import Foundation
import UIKit
import AWSCore
import AWSS3

class MyProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = [Item]()
    var images = [Image]()
    var email = ""
    //var isMyProfile = true
    
    func onLoad() {
        //let defaults = UserDefaults.standard
//        defaults.set(self.isMyProfile,forKey: "isMyProfile")
//            defaults.synchronize()
        
        
        //get email from verification page
        let defaults = UserDefaults.standard;
        
        email = defaults.object(forKey: "email") as! String;
//        let url = URL(string: "http://165.106.136.56:3000/apiUser")
        let url = URL(string: "http://localhost:3000/apiUser?username="+email)

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
                        print("Error: Couldn't decode data into my profile array")
                        return
                    }
                    for item in json {
                        var img = item.image
                        
                        if(img == "") {
                            img = "noimage"
                        }
                        
                        let url = NSURL(string: "https://brynmawrbazaar.s3.amazonaws.com/" + img);
                        var err: NSError?
                        var imageData :NSData = try! NSData(contentsOf: url as! URL,options: NSData.ReadingOptions.mappedIfSafe)
                        var bgImage = UIImage(data:imageData as Data)
                        var i = Image(image: bgImage!, title: item.title)
                        //if i == nil { print("nil photo")}
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
        title = "My Profile"
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
        
        onLoad()
    }

}

extension MyProfileViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
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

extension MyProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC

        // Set values for product details
        detailsVC?.name = items[indexPath.row].title
        detailsVC?.desc = items[indexPath.row].description
        detailsVC?.price = "$ " + items[indexPath.row].price.description
        detailsVC?.venmo = items[indexPath.row].venmo
        detailsVC?.img = images[indexPath.row].image
        
        
        // Show details view controller
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}

//
