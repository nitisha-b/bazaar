//
//  Product.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/5/22.
//

import Foundation
import UIKit

struct Item: Decodable {
    var title: String;
    var description: String;
    var price: Float;
    var image: String;
    //var key: UIImage
 //   var seller: String;
//    var dateAdded: Date;
//    var dateSold: Date;
    var location: String;
    var isService: Bool;   // specify product or service
    var venmo: String;
    var email: String;
}

struct Image {
    var image : UIImage;
    var title: String;
}
