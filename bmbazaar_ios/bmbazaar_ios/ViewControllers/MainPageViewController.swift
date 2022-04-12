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

class MainPageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Arrays to store filtered items and images
    var items = [Item]()
    var itemsSortedByDate = [Item]()
    var imagesSortedByDate = [Item]()
    var images = [Image]()
    var searchItems = [Item]()
    var searchImages = [Image]()
    
    // Temporary arrays used to fetch data from the databases
    var refreshItems = [Item]()
    var refreshImages = [Image]()
    
    var isSortedByDate = false;
    
    let refreshControl = UIRefreshControl()
    var refresher:UIRefreshControl!
    
    @IBOutlet weak var itemType: UISegmentedControl!
    @IBOutlet weak var sortType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        /* Create and set up a new refresher to call the "onLoad" function everytime the page is refreshed */
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(onLoad), for: .valueChanged)
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView!.addSubview(refresher)
        
        // Set segment control to select none
        sortType.selectedSegmentIndex = -1
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
        
        onLoad()
    }
    
    /* Re-sorts items on the collection view when the Products/Services control is switched */
    @IBAction func onItemTypeChanged(_ sender: Any) {
        sortItems()
        self.collectionView.reloadData()
    }
    
    /* Re-sorts items on the collection view when the Cheapest/Newest control is switched */
    @IBAction func onSortTypeChanged(_ sender: Any) {
        sortItems()
        self.collectionView.reloadData()
    }
    
    /* Sorts items based on the filters applied in the segment controls */
    func sortItems() {
        
        self.items.removeAll()
        self.images.removeAll()
        
        //search for products
        if (itemType.selectedSegmentIndex == 1) {
            for (_, item) in self.searchItems.enumerated() {
                if (!item.isService) {
                    items.append(item)
                    for (_, image) in self.searchImages.enumerated(){
                        if (item.image == image.title){
                            images.append(image)
                        }
                    }
                }
            }
            
            //if product and cheapest first are selected
            if (sortType.selectedSegmentIndex == 0) {
                images.removeAll()
                items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
             }
            
            //if product and newest first are selected
            else if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                self.items = items.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
        
        // search for services
        else if (itemType.selectedSegmentIndex == 2) {
            for (_, item) in self.searchItems.enumerated() {
                if (item.isService) {
                    items.append(item)
                    for (_, item) in self.items.enumerated() {
                        for (_, imag) in self.searchImages.enumerated(){
                            if (item.image == imag.title){
                                images.append(imag)
                            }
                        }
                    }
                }
            }
            
            // if services and cheapest first are selected
            if (sortType.selectedSegmentIndex == 0) {
                images.removeAll()
                self.items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
            }
            
            // if services and newest first are selected
            else if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                itemsSortedByDate = items
                self.items = itemsSortedByDate.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
        // search for all
        else if (itemType.selectedSegmentIndex == 0) {
            self.items = self.searchItems
            self.images = self.searchImages
            
            // if all and cheapest are selected
            if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                itemsSortedByDate = items
                self.items = itemsSortedByDate.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
            }
            
            // if all and newest are selected
            else if (sortType.selectedSegmentIndex == 0){
                images.removeAll()
                self.items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
    }
    
    /*
     * Uses the "GET" HTTP endpoint to fetch data from the MongoDB database and the images from the AWS server.
     * Uses temporary arrays to store the items fetched from the databases. The arrays are emptied each time the
     * function is called to avoid overlaps with the filtered items arrays.
     */
    @objc func onLoad() {
//        print("opened")
        refreshItems.removeAll()
        refreshImages.removeAll()
        
//        let ip = "165.106.136.56"
        let ip = "165.106.118.41"
        let localhost = "localhost"

        let url = URL(string: "http://"+ip+":3000/api")
//        let url = URL(string: "http://"+localhost+":3000/api")

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
                        print("Error: Couldn't decode data into Main array")
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
                        var i = Image(image: bgImage!, title: item.image)

                        refreshImages.append(i)
                        refreshItems.append(item)
//                        print("item: \(item)")
                    }
                } catch {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                /* Resets the item arrays everytime the collection view is refreshed */
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    items = refreshItems
                    images = refreshImages
                    searchItems = items
                    searchImages = images
                    itemsSortedByDate = items

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    stopRefresher()
                }
            }
        }
        task.resume()
    }
    
    /* Stops the refresher and resets the segment control filters */
    func stopRefresher() {
        self.refresher.endRefreshing()
        itemType.selectedSegmentIndex = 0
        sortType.selectedSegmentIndex = -1
    }
}

/*
 * Extension of the class to implement the UICollectionViewDataSource
 * This is where data for the collection view is provided and cells are filled in with their respective information
 */
extension MainPageViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.setup(with: items[indexPath.row], with: images[indexPath.row])
        
        return cell
    }
}

/*
 * Extension of the class to implement the UICollectionViewDelegate
 * This is where the current selected cell is used to navigate to the product details page and where the product
 * details page gets the all the information from
 */
extension MainPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as? ProductDetailsVC

        // Set values for product details
        detailsVC?.name = items[indexPath.row].title
        detailsVC?.desc = items[indexPath.row].description
        detailsVC?.price = "$ " + String(format: "%.2f", items[indexPath.row].price)
        detailsVC?.venmo = items[indexPath.row].venmo
        detailsVC?.location = items[indexPath.row].location
        detailsVC?.img = images[indexPath.row].image
        detailsVC?.email = items[indexPath.row].email
        detailsVC?.phone = items[indexPath.row].phoneNum
        
        // Show details view controller
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}
