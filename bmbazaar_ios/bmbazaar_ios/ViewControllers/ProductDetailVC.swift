//
//  ProductDetailVC.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/22/22.
//

import Foundation
import UIKit

class ProductDetailsVC: UIViewController {
    
    @IBOutlet weak var prodTitle: UILabel!
    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var prodDesc: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var sellerVenmo: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    
    
    var name = ""
    var desc = ""
    var price = ""
    var venmo = ""
    var seller = ""
    var imgName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Details"
        
        prodTitle.text = name
        prodDesc.text = desc
        prodPrice.text = price
        sellerVenmo.text = venmo
        sellerName.text = seller
      
    }
    
}
