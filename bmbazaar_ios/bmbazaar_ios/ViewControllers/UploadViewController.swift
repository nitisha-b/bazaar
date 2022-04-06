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
    @IBOutlet weak var phoneNum: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var email = ""
    var formattedPhone = ""
    var phoneDigitsOnly = ""
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        let defaults = UserDefaults.standard;
        email = defaults.object(forKey: "email") as! String;
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.titleText.delegate = self
        self.descText.delegate = self
        self.venmoText.delegate = self
        self.locationText.delegate = self
        self.priceText.delegate = self
        priceText?.addDoneCancelToolbar()
        imagePicker.delegate = self
        self.phoneNum.delegate = self
        phoneNum?.addDoneCancelToolbar()

        title = "Upload"
        
        // set content type for phone number
        phoneNum.textContentType = .telephoneNumber
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
    
   //  To hide the keyboard when press enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }

    
    @IBAction func onClickUpload(_ sender: UIButton!) {
        
        // Exit function if form validation fails
        if (!validateFields()) {
            return
        }
        else {
        
            let imageLength = 10
            let key = generateRandomStringWithLength(length: imageLength)
            
            let image = imageView.image!
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test3.jpeg")
            let imageData = image.jpegData(compressionQuality: 0); fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)

            let fileUrl = NSURL(fileURLWithPath: path)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.bucket = "brynmawrbazaar"
            uploadRequest?.key = key
            uploadRequest?.contentType = "image/jpeg"
            uploadRequest?.body = fileUrl as URL
            //uncomment to add encryption
            //uploadRequest?.serverSideEncryption = AWSS3ServerSideEncryption.awsKms
            uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                DispatchQueue.main.async(execute: {
                                    print("totalBytesSent",totalBytesSent)
                                    print("totalBytesExpectedToSend",totalBytesExpectedToSend)
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
            
            let u = email;
            let username = "&username=" + u;

            let s = Bool(truncating: segControl.selectedSegmentIndex as NSNumber);
            let isService = "&isService=" + String(s);
            let t = titleText.text!
            let title = "title=" + t;
            let d = descText.text ?? "n/a";
            let desc = "&description=" + d;
            let v = venmoText.text ?? "n/a";
            let ven = "&venmo=" + v;
            let l = locationText.text ?? "n/a";
            let loc = "&location=" + l;
            let p = priceText.text!;
            let price = "&price=" + p;
            
            let i: String = key
            let image1: String = "&image=" + i
            
            // format phone number
            formatPhoneNumber()
            let phone = "&phoneNum=" + formattedPhone
            
            let ip = "165.106.136.56"
            let localhost = "localhost"
            
            //upload to users
            //change to localhost to ip if using an physical device
            var urlStr = "http://"+ip+":3000/addItemToUser?"+title+desc+ven+loc+price+isService+image1+username+"&email="+u+phone;
    //
//            var urlStr = "http://"+localhost+":3000/addItemToUser?"+title+desc+ven+loc+price+isService+image1+username+"&email="+u+phone;
            
            //upload to items
            var urlStr2 = "http://"+ip+":3000/createItemInApp?"+title+desc+ven+loc+price+isService+image1+"&email="+u+phone;
//            var urlStr2 = "http://"+localhost+":3000/createItemInApp?"+title+desc+ven+loc+price+isService+image1+"&email="+u+phone;
            
            urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            urlStr2 = urlStr2.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let url = URL(string: urlStr)!;
            let url2 = URL(string: urlStr2)!;

            var request = URLRequest(url: url);
            var request2 = URLRequest(url: url2);

            let body = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":s, "image":i, "username":u, "email":u, "phoneNum":formattedPhone] as [String : Any];
            let body2 = ["title":t, "description":d, "venmo":v, "location":l, "price":p, "isService":s, "image":i, "email":u, "phoneNum":formattedPhone] as [String : Any];

            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
            let bodyData2 = try? JSONSerialization.data(withJSONObject: body2, options: [])

            request.httpMethod = "POST"
            request2.httpMethod = "POST"
            
            request.httpBody = bodyData;
            request2.httpBody = bodyData2;
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
            
            let task2 = session.dataTask(with: request2) { (data2, response, error) in
                
                if let data2 = data2 {
                    print("Data successfully posted in the database! \(data2)")
                    isPosted = true
                }
                else if let error = error {
                    print("Http request failed \(error)")
                }
            }
            task2.resume()
        }
    }
    
    /* Checks if the user entered all the required fields in the Upload page */
    func validateFields() -> Bool {
        
        // Title and Price are required and cannot be left blank
        if (titleText.text == nil || titleText.text == "" || priceText.text == nil || priceText.text == "") {
            let alert = UIAlertController(title: "Uh Oh", message: "Please enter all required fields", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        // Phone number cannot be less or greater than 10 digits
        
//        let num = phoneNum.text?.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression) ?? ""
        formatPhoneNumber()
        
        if (phoneDigitsOnly.count != 0 && phoneDigitsOnly.count != 10) {
            let alert = UIAlertController(title: "Uh Oh", message: "Please enter a valid phone number", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func formatPhoneNumber() {
        let phoneText = phoneNum.text ?? "n/a"
        phoneDigitsOnly = phoneText.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
        formattedPhone = phoneDigitsOnly.toPhoneNumber()
    }
    
    func displayAlert(isPosted: Bool) {
        
        if (isPosted) {
            // Create a new alert
            let postedAlert = UIAlertController(title: "Yay!", message: "Product successfully posted!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { (aciton) ->Void in
                print("OK button tapped")
                
                // return to main page
                let mainPageVC = self.storyboard?.instantiateViewController(withIdentifier: "homepage") as? MainPageViewController
                self.navigationController?.pushViewController(mainPageVC!, animated: true)
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
        self.imageView.image = UIImage(named: "noimage")
        self.phoneNum.text = ""
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

extension String {
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
}
