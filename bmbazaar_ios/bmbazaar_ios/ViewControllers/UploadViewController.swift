//
//  UploadViewController.swift
//  bmbazaar_ios
//
//  Created by Nitisha on 2/9/22.
//

import Foundation
import UIKit
import AWSCore
import AWSS3
import Photos

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

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
        self.titleText.delegate = self
        self.descText.delegate = self
        self.venmoText.delegate = self
        self.locationText.delegate = self
        self.priceText.delegate = self
        priceText?.addDoneCancelToolbar()
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
    
    // To generate random key
    func generateRandomStringWithLength(length: Int) -> String {
        let randomString: NSMutableString = NSMutableString(capacity: length)
        let letters: NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var i: Int = 0

        while i < length {
            let randomIndex: Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }
        return String(randomString)
    }
    
    // To hide the keyboard when press enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }

    
    @IBAction func onClickUpload(_ sender: UIButton!) {
        let imageLength = 10
        let key = generateRandomStringWithLength(length: imageLength)
        
        let image = imageView.image!
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test3.jpeg")
        let imageData = image.jpegData(compressionQuality: 0); fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)

        let fileUrl = NSURL(fileURLWithPath: path)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        //AWSConfigsS3.UseSignatureVersion4 = true;
        uploadRequest?.bucket = "brynmawrbazaar"
        uploadRequest?.key = key
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.body = fileUrl as URL
        //uploadRequest?.serverSideEncryption = AWSS3ServerSideEncryption.awsKms
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                                print("totalBytesSent",totalBytesSent)
                                print("totalBytesExpectedToSend",totalBytesExpectedToSend)

//                                self.amountUploaded = totalBytesSent // To show the updating data status in label.
//                                self.fileSize = totalBytesExpectedToSend
                            })
                        }
        print(fileUrl as URL)
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                        if task.error != nil {
                                // Error.
                            print(task.error ?? "default value")
                            } else {
                                // Do something with your result.
                            print("No error Upload Done")
                            }
                            return nil
                        })
        

        let s = Bool(truncating: segControl.selectedSegmentIndex as NSNumber);
        let isService = "&isService=" + String(s);
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
        
//        let uiImage : UIImage = imageView.image!
//        let imageData : Data = uiImage.jpegData(compressionQuality: 0) ?? Data()
//        var i : String = imageData.base64EncodedString()
//
//        i = i.replacingOccurrences(of: "+", with: "%2B")
//        i = i.replacingOccurrences(of: "/", with: "%2F")
//        i = i.replacingOccurrences(of: "=", with: "%3D")
        let i: String = key
        let image1: String = "&image=" + i
//        let i = convertImageToBase64String(img: imageView.image! );
//        let image = "&image=" + i;
        
        
        
        
        
        print(image1)
        
        var urlStr = "http://165.106.136.56:3000/createItemInApp?"+title+desc+ven+loc+price+isService+image1;
//        var urlStr = "http://localhost:3000/create?"+title+desc+ven+loc+price+"&isService="+String(isService);
//        print(urlStr);
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: urlStr)!;

        var request = URLRequest(url: url);

        let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":s, "image":i] as [String : Any];
//        let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":isService] as [String : Any];
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

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
