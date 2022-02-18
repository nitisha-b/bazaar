//
//  UploadViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/9/22.
//

import Foundation
import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var venmoText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickUpload(_ sender: UIButton!) {

//        url string;
        let isService = Bool(truncating: segControl.selectedSegmentIndex as NSNumber);
        //let isService = false;
        let t = titleText.text!
        //let t = "Phone";
        let title = "title=" + t;
        let d = descText.text ?? "";
        //let d = "hello"
        let desc = "&description=" + d;
        let v = venmoText.text ?? "";
        //let v  = "@nitisha";
        let ven = "&venmo=" + v;
        let l = locationText.text ?? "";
        //let l = "rock"
        let loc = "&location=" + l;
        let p = priceText.text!;
        //let p = "10"
        let price = "&price=" + p;
        var urlStr = "http://localhost:3000/create?"+title+desc+ven+loc+price+"&isService="+String(isService);
        print(urlStr);
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: urlStr)!;

        var request = URLRequest(url: url);

        let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":isService] as [String : Any];
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])

        request.httpMethod = "POST"
        request.httpBody = bodyData;
        var isPosted = false;
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                print("Data successfully posted in the database! \(data)")
                isPosted = true
            }
            else if let error = error {
                print("Http request failed \(error)")
            }
            
            DispatchQueue.main.async {
                self.displayAlert(isPosted: isPosted)
                self.clearForm()
            }
        }
        task.resume()
    }
    
    func displayAlert(isPosted: Bool) {
        
        if (isPosted) {
            // Create a new alert
            let postedAlert = UIAlertController(title: "Yay!", message: "Product successfully posted!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { (aciton) ->Void in
                print("OK button tapped")
            }
            postedAlert.addAction(ok)
            self.present(postedAlert, animated: true, completion: nil)
        }
    
    }
    
    func clearForm() {
        self.titleText.text = ""
        self.descText.text = ""
        self.venmoText.text = ""
        self.locationText.text = ""
        self.priceText.text = ""
        self.segControl.selectedSegmentIndex = 0;
    }
}
