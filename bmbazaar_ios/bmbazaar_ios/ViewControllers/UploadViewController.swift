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
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
    }
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    @IBAction func onClickUpload(_ sender: UIButton!) {

        let isService = Bool(truncating: segControl.selectedSegmentIndex as NSNumber);
        let t = titleText.text!
        let title = "title=" + t;
        let d = descText.text ?? "";
        let desc = "&description=" + d;
        let v = venmoText.text ?? "";
        let ven = "&venmo=" + v;
        let l = locationText.text ?? "";
        let loc = "&location=" + l;
        let p = priceText.text!;
        let price = "&price=" + p;
        
        let image = "&image=" + convertImageToBase64String(img: imageView.image! );
        
        
        print(image)
        
        var urlStr = "http://localhost:3000/create?"+title+desc+ven+loc+price+"&isService="+String(isService) + image;
        print(urlStr);
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: urlStr)!;

        var request = URLRequest(url: url);

        let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":isService, "image":image] as [String : Any];
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
