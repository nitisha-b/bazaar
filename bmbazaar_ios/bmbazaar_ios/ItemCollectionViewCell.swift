//
//  ProductCollectionViewCell.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/16/22.
//

import Foundation
import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var seller: UILabel!
    
    func setup(with item: Item) {
        title.text = item.title;
        price.text = String(item.price)
        //seller.text = item.seller
        //title.text = "HI"
        //price.text = "10.00"
        
        itemImage.image = UIImage(named: "avatar-5")
        
    }
    
    
}
