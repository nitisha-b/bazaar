//
//  SearchBarView.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 3/18/22.
//

import Foundation
import UIKit

//class SearchBarView: UIViewController, UISearchBarDelegate {
class SearchBarView: UICollectionReusableView {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
//
//    var items = [Item]()
//    var images = [Image]()
//
//    var searchItems = [Item]()
//    var searchImages = [Image]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // get data from homepage
//        let mainVC = storyboard?.instantiateViewController(withIdentifier: "homepage") as? MainPageViewController
//        items = mainVC!.items
//        images = mainVC!.images
//
//        searchItems = mainVC!.items
//        searchImages = mainVC!.images
//
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        self.items.removeAll()
//
//        for item in self.searchItems {
//            if (item.title.lowercased().contains(searchBar.text!.lowercased())) {
//                self.items.append(item)
//            }
//        }
//
//        // If the search is blank
//        if (searchBar.text!.isEmpty) {
//            self.items = self.searchItems
//        }
//
////        collectionView.reloadData()
//    }
//
////    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
////
////        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchbar", for: indexPath)
////        return searchView
////    }
}
