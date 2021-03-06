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
    
    // Temporary arrays
    var refreshItems = [Item]()
    var refreshImages = [Image]()
    
    var email = ""
    
    let refreshControl = UIRefreshControl()
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Profile"
        
        /* Create and set up a new refresher to call the "onLoad" function everytime the page is refreshed */
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(onLoad), for: .valueChanged)
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView!.addSubview(refresher)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
        
        onLoad()
    }

    /*
     * Uses the "GET" HTTP endpoint to fetch data from the MongoDB database and the images from the AWS server.
     * Uses temporary arrays to store the items fetched from the databases. The arrays are emptied each time the
     * function is called to avoid overlaps with the filtered items arrays.
     */
    @objc func onLoad() {
        refreshItems.removeAll()
        refreshImages.removeAll()
        
        //get email from verification page
        let defaults = UserDefaults.standard;
        email = defaults.object(forKey: "email") as! String;
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //        let ip = "165.106.136.56"
        let ip = "165.106.118.41"
        let localhost = "localhost"

        // Change to localhost to ip if using an physical device
        let url = URL(string: "http://"+ip+":3000/apiUser?username="+email)
//        let url = URL(string: "http://"+localhost+":3000/apiUser?username="+email)
        
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

                        refreshItems.append(item)
                        refreshImages.append(i)
                    }
                } catch {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                /* Resets the item arrays everytime the collection view is refreshed */
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    items = refreshItems
                    images = refreshImages
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    stopRefresher()
                }
            }
        }
        task.resume()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
}

/*
 * Extension of the class to implement the UICollectionViewDataSource
 * This is where data for the collection view is provided and cells are filled in with their respective information
 */
extension MyProfileViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.setup(with: items[indexPath.row], with: images[indexPath.row])
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

/*
 * Extension of the class to implement the UICollectionViewDelegate
 * This is where the current selected cell is used to navigate to the product details page and where the product details page gets the all the information from
 */
extension MyProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC

        // Set values for product details
        detailsVC?.name = items[indexPath.row].title
        detailsVC?.desc = items[indexPath.row].description
        detailsVC?.price = "$ " + String(format: "%.2f", items[indexPath.row].price)
        detailsVC?.venmo = items[indexPath.row].venmo
        detailsVC?.img = images[indexPath.row].image
        detailsVC?.email = items[indexPath.row].email
        detailsVC?.phone = items[indexPath.row].phoneNum
        detailsVC?.location = items[indexPath.row].location
        
        
        // Show details view controller
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}

