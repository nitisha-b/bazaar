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
    
    
    var items = [Item]()
    var itemsSortedByDate = [Item]()
    var imagesSortedByDate = [Item]()
    var images = [Image]()
    
    // Items for search bar
    var searchItems = [Item]()
    var searchImages = [Image]()
    var refreshItems = [Item]()
    var refreshImages = [Image]()
    
    var isSortedByDate = false;
    
    let refreshControl = UIRefreshControl()
    
    var refresher:UIRefreshControl!

    
    @IBOutlet weak var itemType: UISegmentedControl!
    @IBOutlet weak var sortType: UISegmentedControl!
    
    @IBAction func onItemTypeChanged(_ sender: Any) {
        
        // index=0: all, index=1: product, index=2: service
        print("filter: \(itemType.selectedSegmentIndex.description )")
        sortItems()
        self.collectionView.reloadData()
    }
    
    @IBAction func onSortTypeChanged(_ sender: Any) {
        sortItems()
        self.collectionView.reloadData()
    }
    
    func sortItems() {
        self.items.removeAll()
        self.images.removeAll()
        
        if (itemType.selectedSegmentIndex == 1) {
            for (idx, item) in self.searchItems.enumerated() {
                if (!item.isService) {
                    items.append(item)
                    for (_, image) in self.searchImages.enumerated(){
                        if (item.image == image.title){
                            images.append(image)
                        }
                    }
                }
            }
            if (sortType.selectedSegmentIndex == 0) {
                images.removeAll()
                items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
             }
            else if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                //itemsSortedByDate = items
                self.items = items.reversed()
                //self.images = images.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
        
        // search for services
        else if (itemType.selectedSegmentIndex == 2) {
            for (idx, item) in self.searchItems.enumerated() {
                if (item.isService) {
                    items.append(item)
                    for (_, item) in self.items.enumerated() {
                        for (_, imag) in self.searchImages.enumerated(){
                            if (item.image == imag.title){
                                print("item.image: \(item.image) image.title\(imag.title)")
                                images.append(imag)
                            }
                        }
                    }
                }
            }
            if (sortType.selectedSegmentIndex == 0) {
                images.removeAll()
                self.items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
            }
            else if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                itemsSortedByDate = items
                self.items = itemsSortedByDate.reversed()
                //self.images = images.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
        // If the search is blank
        else if (itemType.selectedSegmentIndex == 0) {
            self.items = self.searchItems
            self.images = self.searchImages
            
            if(sortType.selectedSegmentIndex == 1) {
                images.removeAll()
                itemsSortedByDate = items
                self.items = itemsSortedByDate.reversed()
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
            }
            else if (sortType.selectedSegmentIndex == 0){
                images.removeAll()
                self.items = items.sorted(by: { $0.price < $1.price })
                for (_, item) in self.items.enumerated() {
                    for (_, imag) in self.searchImages.enumerated(){
                        if (item.image == imag.title){
                            print("item.image: \(item.image) image.title\(imag.title)")
                            images.append(imag)
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func onLoad() {
        print("opened")
//        items.removeAll()
//        images.removeAll()
//        searchItems.removeAll()
//        searchImages.removeAll()
//        itemsSortedByDate.removeAll()
        refreshItems.removeAll()
        refreshImages.removeAll()
        
        
        let ip = "165.106.136.56"
        let localhost = "localhost"
//        self.collectionView!.refreshControl?.beginRefreshing()
        
//        let url = URL(string: "http://165.106.136.56:3000/api")
        let url = URL(string: "http://"+ip+":3000/api")

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
                        //if i == nil { print("nil photo")}
//                        images.append(i)
//                        searchImages.append(i)
                        refreshImages.append(i)
                        
                        //item.image = bgImage
//                        items.append(item)
//                        itemsSortedByDate.append(item)
//                        searchItems.append(item)
                        refreshItems.append(item)
                        
                    }
                } catch {
                    print("Failed to load: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    items = refreshItems
                    images = refreshImages
                    searchItems = items
                    searchImages = images
                    itemsSortedByDate = items
                    
//                    stopRefresher()
                        //refreshControl.endRefreshing()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    stopRefresher()
                    //sortItems()
                }

            }

        }
        task.resume()
    }
    
    func stopRefresher() {
//        self.collectionView!.refreshControl?.endRefreshing()
        self.refresher.endRefreshing()
        itemType.selectedSegmentIndex = 0
        sortType.selectedSegmentIndex = -1
    }
//    @objc func refreshData() {
//            //onLoad()
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//            self.refresher.endRefreshing()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(onLoad), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
        
        sortType.selectedSegmentIndex = -1
        title = "Home"
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
        
        onLoad()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        self.collectionView.reloadData()
//    }

}

extension MainPageViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.setup(with: items[indexPath.row], with: images[indexPath.row])
        
        return cell
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
}

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
        
        // Show details view controller
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}
